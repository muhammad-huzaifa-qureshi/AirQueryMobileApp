import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const resolveQuery = onCall(async (request) => {
  // Auth guard
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Please log in to continue.");
  }

  // Email verification check
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
    throw new HttpsError("invalid-argument", "Query ID is required.");
  }

  // Fetch query doc
  const querySnap = await db.collection("queries").doc(queryId).get();
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

  // Delete query
  await db.collection("queries").doc(queryId).delete();

  // Increment queriesResolved on user doc
  await db.collection("users").doc(uid).update({
    queriesResolved: admin.firestore.FieldValue.increment(1),
  });

  // Increment platform stats
  await db.collection("platformStats").doc("global").update({
    totalQueriesResolved: admin.firestore.FieldValue.increment(1),
  });

  return {success: true};
});
