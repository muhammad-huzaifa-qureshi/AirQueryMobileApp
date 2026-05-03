import * as admin from "firebase-admin";

/**
 * Updates postedBy map in batches of 499 to stay
 * within Firestore's 500 ops limit.
 * @param {admin.firestore.Firestore} db - Firestore instance
 * @param {admin.firestore.QueryDocumentSnapshot[]} docs - Docs to update
 * @param {Object} fields - Fields to update
 * @return {Promise<void>}
 */
export async function batchUpdatePostedBy(
  db: admin.firestore.Firestore,
  docs: admin.firestore.QueryDocumentSnapshot[],
  fields: Partial<{ name: string; isInsider: boolean; isPremium: boolean }>
): Promise<void> {
  const chunkSize = 499;

  for (let i = 0; i < docs.length; i += chunkSize) {
    const batch = db.batch();
    docs.slice(i, i + chunkSize).forEach((doc) => {
      const update: Record<string, unknown> = {};
      if (fields.name !== undefined) update["postedBy.name"] = fields.name;
      if (fields.isInsider !== undefined) {
        update["postedBy.isInsider"] =
      fields.isInsider;
      }
      if (fields.isPremium !== undefined) {
        update["postedBy.isPremium"] =
      fields.isPremium;
      }
      batch.update(doc.ref, update);
    });

    await batch.commit();
  }
}


