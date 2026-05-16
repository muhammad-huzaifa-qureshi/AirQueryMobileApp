import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

/** Deletes a query. Cleanup is handled by the query delete trigger. */
export const deleteQuery = onCall(
  {maxInstances: 1, enforceAppCheck: true},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Please log in to continue.");
    }
    if (!request.auth.token.email_verified) {
      throw new HttpsError(
        "failed-precondition",
        "Please verify your email to continue."
      );
    }

    const uid = request.auth.uid;
    const db = admin.firestore();
    const {queryId} = request.data;

    if (!queryId) {
      throw new HttpsError(
        "invalid-argument",
        "Query ID is missing, please try again!"
      );
    }

    const queryRef = db.collection("queries").doc(queryId);
    const querySnap = await queryRef.get();

    if (!querySnap.exists) {
      throw new HttpsError("not-found", "Query not found.");
    }

    // Ownership check
    if (querySnap.data()?.postedBy?.uid !== uid) {
      throw new HttpsError(
        "permission-denied",
        "You can only delete your own queries."
      );
    }

    await queryRef.delete();

    return {success: true};
  });
