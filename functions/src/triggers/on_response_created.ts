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
    const mentionedUid = data.mentionedUid as string | undefined;

    const db = admin.firestore();

    try {
      // to get query owner
      const querySnap = await db
        .collection("queries")
        .doc(queryId)
        .get();

      if (!querySnap.exists) return;

      const queryOwnerUid = querySnap.data()?.postedBy?.uid as string;

      // Notify owner if someone else responded
      if (queryOwnerUid && queryOwnerUid !== posterUid) {
        const ownerTokenSnap = await db
          .collection("users")
          .doc(queryOwnerUid)
          .collection("private")
          .doc("fcmToken")
          .get();

        const ownerToken = ownerTokenSnap.data()?.token as string | undefined;
        if (ownerToken) {
          await admin.messaging().send({
            token: ownerToken,
            notification: {
              title: "New Response",
              body: `${posterName} replied to your query.`,
            },
            data: {type: "new_response", queryId},
          });
        }
      }

      // Notify mentioned user:
      // skip if they're the query owner
      // (they get response notification instead)
      if (mentionedUid &&
        mentionedUid !== posterUid &&
        mentionedUid !== queryOwnerUid) {
        const mentionTokenSnap = await db
          .collection("users")
          .doc(mentionedUid)
          .collection("private")
          .doc("fcmToken")
          .get();

        const mentionToken = mentionTokenSnap.data()
          ?.token as string | undefined;
        if (mentionToken) {
          await admin.messaging().send({
            token: mentionToken,
            notification: {
              title: "You were mentioned",
              body: `${posterName} mentioned you in a response.`,
            },
            data: {type: "mention", queryId},
          });
        }
      }
    } catch (e) {
      console.error("Notification failed:", e);
    }
  });
