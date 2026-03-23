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
      // Fetch users by campus
      let usersSnap;
      if (campus === "All") {
        usersSnap = await db.collection("users").get();
      } else {
        usersSnap = await db
          .collection("users")
          .where("campus", "==", campus)
          .get();
      }

      const eligibleDocs = usersSnap.docs.filter(
        (doc) => doc.id !== posterUid
      );

      if (eligibleDocs.length === 0) return;

      // Fetch fcmToken from each user's subcollection in parallel
      const tokenResults = await Promise.all(
        eligibleDocs.map((doc) =>
          db
            .collection("users")
            .doc(doc.id)
            .collection("private")
            .doc("fcmToken")
            .get()
        )
      );

      const tokens = tokenResults
        .filter((snap) => snap.exists && snap.data()?.token)
        .map((snap) => snap.data()?.token as string)
        .filter((token): token is string => !!token);

      if (tokens.length === 0) return;

      const notifBody = campus === "All" ?
        "A new query was posted for all campuses." :
        `A new query was posted for ${campus}.`;

      // FCM max 500 tokens per multicast
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
    } catch (e) {
      console.error("Notification failed:", e);
    }
  });
