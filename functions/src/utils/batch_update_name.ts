import * as admin from "firebase-admin";

/**
 * Updates postedBy.name in batches of 499 to stay
 * within Firestore's 500 ops limit.
 * @param {admin.firestore.Firestore} db - Firestore instance
 * @param {admin.firestore.QueryDocumentSnapshot[]} docs - Docs to update
 * @param {string} name - New display name
 * @return {Promise<void>}
 */
export async function batchUpdateName(
  db: admin.firestore.Firestore,
  docs: admin.firestore.QueryDocumentSnapshot[],
  name: string
): Promise<void> {
  const chunkSize = 499;

  for (let i = 0; i < docs.length; i += chunkSize) {
    const batch = db.batch();
    docs.slice(i, i + chunkSize).forEach((doc) =>
      batch.update(doc.ref, {"postedBy.name": name})
    );

    await batch.commit();
  }
}
