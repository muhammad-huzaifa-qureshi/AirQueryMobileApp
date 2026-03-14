import { onCall, HttpsError } from "firebase-functions/v2/https";
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
  const { queryId } = request.data;

  if (!queryId) {
    throw new HttpsError("invalid-argument", "Query ID is required.");
  }

  // Fetch query doc
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

  // Delete all responses in subcollection (chunked for 500+ responses)
  const responsesSnap = await queryRef.collection("responses").get();
  const chunkSize = 499;
  for (let i = 0; i < responsesSnap.docs.length; i += chunkSize) {
    const batch = db.batch();
    responsesSnap.docs.slice(i, i + chunkSize)
      .forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }

  // Delete query
  await queryRef.delete();

  // Increment queriesResolved on user doc
  await db.collection("users").doc(uid).update({
    queriesResolved: admin.firestore.FieldValue.increment(1),
  });

  // Increment platform stats
  await db.collection("platformStats").doc("global").update({
    totalQueriesResolved: admin.firestore.FieldValue.increment(1),
  });

  return { success: true };
});
