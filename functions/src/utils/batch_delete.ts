import * as admin from "firebase-admin";

/**
 * Deletes all docs in chunks of 499 to stay within Firestore's 500 ops limit.
 * @param {admin.firestore.Firestore} db - Firestore instance
 * @param {admin.firestore.QueryDocumentSnapshot[]} docs - Docs to delete
 * @return {Promise<void>}
 */
export async function batchDelete(
  db: admin.firestore.Firestore,
  docs: admin.firestore.QueryDocumentSnapshot[]
): Promise<void> {
  const chunkSize = 499;
  for (let i = 0; i < docs.length; i += chunkSize) {
    const batch = db.batch();
    docs.slice(i, i + chunkSize).forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  }
}
