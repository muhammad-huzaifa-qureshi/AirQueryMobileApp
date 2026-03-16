import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

/**
 * Deletes all docs in chunks of 499 to stay within Firestore's 500 ops limit.
 * @param {admin.firestore.QueryDocumentSnapshot[]} docs - Docs to delete
 * @return {Promise<void>}
 */
async function batchDelete(
  docs: admin.firestore.QueryDocumentSnapshot[]
): Promise<void> {
  const db = admin.firestore();
  const chunkSize = 499;
  for (let i = 0; i < docs.length; i += chunkSize) {
    const batch = db.batch();
    docs.slice(i, i + chunkSize).forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }
}

/** Deletes user account, their queries, responses, and record. */
export const deleteAccount = onCall(
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

  // Fetch all user's queries
  const queriesSnap = await db
    .collection("queries")
    .where("postedBy.uid", "==", uid)
    .get();

  // Delete all responses inside each of user's queries
  await Promise.all(
    queriesSnap.docs.map(async (queryDoc) => {
      const responsesSnap = await queryDoc.ref.collection("responses").get();
      await batchDelete(responsesSnap.docs);
    })
  );

  // Delete all user's queries
  await batchDelete(queriesSnap.docs);

  // Delete user's responses on other people's queries
  const myResponsesSnap = await db
    .collectionGroup("responses")
    .where("postedBy.uid", "==", uid)
    .get();
  await batchDelete(myResponsesSnap.docs);

  // Delete user doc
  await db.collection("users").doc(uid).delete();

  // Delete Firebase Auth user last
  await admin.auth().deleteUser(uid);

  return {success: true};
});
