import {onDocumentDeleted} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {batchDelete} from "../utils/batch_delete";

/** Cleans up query-owned resources after any query document deletion. */
export const onQueryDeleted = onDocumentDeleted(
  "queries/{queryId}",
  async (event) => {
    const deletedSnap = event.data;
    if (!deletedSnap) return;

    const db = admin.firestore();
    const data = deletedSnap.data();
    const imagePath = data?.imagePath as string | undefined;

    if (imagePath) {
      try {
        await admin.storage()
          .bucket()
          .file(imagePath)
          .delete({ignoreNotFound: true});
      } catch (e) {
        console.error("Query image cleanup failed:", {
          queryId: event.params.queryId,
          imagePath,
          error: e,
        });
      }
    }

    try {
      const responsesSnap = await deletedSnap.ref.collection("responses").get();
      await batchDelete(db, responsesSnap.docs);
    } catch (e) {
      console.error("Query responses cleanup failed:", {
        queryId: event.params.queryId,
        error: e,
      });
    }
  }
);
