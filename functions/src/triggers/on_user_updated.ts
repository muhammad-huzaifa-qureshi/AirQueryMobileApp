import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {batchUpdatePostedBy} from "../utils/batch_update_posted_by";

export const onUserUpdated = onDocumentUpdated(
  "users/{uid}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    const premiumChanged = before.isPremium !== after.isPremium;

    // Only run if isPremium actually changed
    // (name and isInsider are handled inside the updateProfile callable)
    if (!premiumChanged) return;

    const uid = event.params.uid;
    const db = admin.firestore();

    const [querySnap, responseSnap] = await Promise.all([
      db.collection("queries")
        .where("postedBy.uid", "==", uid).get(),
      db.collectionGroup("responses")
        .where("postedBy.uid", "==", uid).get(),
    ]);

    await Promise.all([
      batchUpdatePostedBy(db, querySnap.docs, {isPremium: after.isPremium}),
      batchUpdatePostedBy(db, responseSnap.docs, {isPremium: after.isPremium}),
    ]);
  }
);
