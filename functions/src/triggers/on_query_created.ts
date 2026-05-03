import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {Constants} from "../constants";

/** Sends an FCM notification to all subscribed
users when a new query is posted. */
export const onQueryCreated = onDocumentCreated(
  "queries/{queryId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const posterUid = data.postedBy?.uid as string;
    const queryId = event.params.queryId;

    try {
      // Send to the global topic — all users receive this notification.
      await admin.messaging().send({
        topic: Constants.fcmTopicAllUsers,
        notification: {
          title: "New Query Posted!",
          body: "A fresh question just dropped. " +
          "jump in and share your knowledge!",
        },
        data: {
          type: "new_query",
          queryId,
          posterUid,
        },
      });
    } catch (err) {
      console.error("FCM topic notification failed:", err);
    }
  }
);
