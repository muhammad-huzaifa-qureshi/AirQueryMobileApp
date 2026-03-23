import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

/** Notifies query owner when a new response is posted. */
export const onResponseCreated = onDocumentCreated(
  "queries/{queryId}/responses/{responseId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const posterUid = data.postedBy?.uid as string;
    const posterName = data.postedBy?.name as string;
    const queryId = event.params.queryId;

    const db = admin.firestore();

    try {
      // Extra read to get query owner
      const querySnap = await db
        .collection("queries")
        .doc(queryId)
        .get();

      if (!querySnap.exists) return;

      const queryOwnerUid = querySnap.data()?.postedBy?.uid as string;

      // Don't notify if owner is the one responding
      if (!queryOwnerUid || queryOwnerUid === posterUid) return;

      const ownerTokenSnap = await db
        .collection("users")
        .doc(queryOwnerUid)
        .collection("private")
        .doc("fcmToken")
        .get();

      const ownerToken = ownerTokenSnap.data()?.token as string | undefined;
      if (!ownerToken) return;

      await admin.messaging().send({
        token: ownerToken,
        notification: {
          title: "New Response",
          body: `${posterName} replied to your query.`,
        },
        data: {
          type: "new_response",
          queryId,
        },
      });
    } catch (e) {
      console.error("Notification failed:", e);
    }
  });
