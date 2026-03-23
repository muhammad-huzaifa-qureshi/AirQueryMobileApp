import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {batchDelete} from "../utils/batch_delete";

/** Resolves a query — deletes it, its responses, and updates counters. */
export const resolveQuery = onCall(
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
        "You can only resolve your own queries."
      );
    }

    // Delete all responses first
    const responsesSnap = await queryRef.collection("responses").get();
    await batchDelete(db, responsesSnap.docs);

    // Atomically delete query + update counters
    const userRef = db.collection("users").doc(uid);
    const statsRef = db.collection("platformStats").doc("global");

    await db.runTransaction(async (tx) => {
      // Re-read query inside transaction to confirm it still exists
      const freshSnap = await tx.get(queryRef);
      if (!freshSnap.exists) {
        throw new HttpsError("not-found", "Query no longer exists.");
      }

      tx.delete(queryRef);
      tx.update(userRef, {
        queriesResolved: admin.firestore.FieldValue.increment(1),
      });
      tx.set(
        statsRef,
        {totalQueriesResolved: admin.firestore.FieldValue.increment(1)},
        {merge: true}
      );
    });

    return {success: true};
  });
