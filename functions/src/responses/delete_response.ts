import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

/** Deletes own response and decrements responseCount. */
export const deleteResponse = onCall(
  {maxInstances: 1, enforceAppCheck: true},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Please log in to continue.");
    }

    if (!request.auth.token.email_verified) {
      throw new HttpsError(
        "failed-precondition",
        "Please verify your email to continue.");
    }

    const uid = request.auth.uid;
    const db = admin.firestore();
    const {queryId, responseId} = request.data;

    if (!queryId || !responseId) {
      throw new HttpsError(
        "invalid-argument",
        "Query ID and Response ID are missing, please try again!");
    }

    const queryRef = db.collection("queries").doc(queryId);
    const responseRef = queryRef.collection("responses").doc(responseId);

    const responseSnap = await responseRef.get();
    if (!responseSnap.exists) {
      throw new HttpsError("not-found", "Response not found.");
    }

    // Ownership check
    if (responseSnap.data()?.postedBy?.uid !== uid) {
      throw new HttpsError(
        "permission-denied",
        "You can only delete your own responses.");
    }

    // Delete response + decrement responseCount atomically
    await db.runTransaction(async (tx) => {
      tx.delete(responseRef);
      tx.update(queryRef, {
        responseCount: admin.firestore.FieldValue.increment(-1),
      });
    });

    return {success: true};
  });
