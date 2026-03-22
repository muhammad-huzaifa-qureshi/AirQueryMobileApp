import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {batchUpdateName} from "../utils/batch_update_name";

export const syncUserName = onCall(
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
    const {name} = request.data;

    if (!name) {
      throw new HttpsError("invalid-argument", "Name is required.");
    }

    const db = admin.firestore();

    // Fetch all queries and responses by this user in parallel
    const [querySnap, responseSnap] = await Promise.all([
      db.collection("queries").where("postedBy.uid", "==", uid).get(),
      db.collectionGroup("responses").where("postedBy.uid", "==", uid).get(),
    ]);

    // Batch update in parallel
    await Promise.all([
      batchUpdateName(db, querySnap.docs, name),
      batchUpdateName(db, responseSnap.docs, name),
    ]);

    return {success: true};
  });
