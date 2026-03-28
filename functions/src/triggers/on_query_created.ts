import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

/** Sends FCM notifications to campus users when a new query is posted. */
export const onQueryCreated = onDocumentCreated(
  "queries/{queryId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const campus = data.campus as string;
    const posterUid = data.postedBy?.uid as string;
    const queryId = event.params.queryId;
    const db = admin.firestore();

    try {
      const tokens: string[] = [];

      if (campus === "All") {
        // Fetch all campus token docs
        const fcmSnap = await db.collection("fcmTokens").get();

        fcmSnap.docs.forEach((doc) => {
          const campusTokens = doc.data() ?? {};
          Object.entries(campusTokens).forEach(([uid, token]) => {
            if (uid !== posterUid && typeof token === "string") {
              tokens.push(token);
            }
          });
        });
      } else {
        // Fetch tokens only for the specific campus
        const doc = await db.collection("fcmTokens").doc(campus).get();
        if (doc.exists) {
          const campusTokens = doc.data() ?? {};
          Object.entries(campusTokens).forEach(([uid, token]) => {
            if (uid !== posterUid && typeof token === "string") {
              tokens.push(token);
            }
          });
        }
      }

      if (tokens.length === 0) return;

      const notifBody =
        campus === "All" ?
          "A new query was posted for all campuses." :
          `A new query was posted for ${campus}.`;

      // Send FCM in chunks of 500 tokens
      const chunkSize = 500;
      for (let i = 0; i < tokens.length; i += chunkSize) {
        await admin.messaging().sendEachForMulticast({
          tokens: tokens.slice(i, i + chunkSize),
          notification: {
            title: "New Query Posted!",
            body: notifBody,
          },
          data: {
            type: "new_query",
            queryId,
            posterUid,
          },
        });
      }
    } catch (err) {
      console.error("FCM notification failed:", err);
    }
  }
);
