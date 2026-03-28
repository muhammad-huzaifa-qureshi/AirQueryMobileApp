import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

/** Syncs user FCM token to campus-level map on re-login */
export const syncFcmTokenInMap = onDocumentWritten(
  "users/{uid}/private/fcmToken",
  async (event) => {
    const uid = event.params.uid;
    const newToken = event.data?.after?.data()?.token as string | undefined;
    if (!newToken) return;

    const db = admin.firestore();

    try {
      // Get user's current campus
      const userSnap = await db.collection("users").doc(uid).get();
      const campus = userSnap.data()?.campus as string | undefined;
      if (!campus) return;

      const campusDocRef = db.collection("fcmTokens").doc(campus);

      // Set / update the token in the campus-level FCM map
      await campusDocRef.set({[uid]: newToken}, {merge: true});
    } catch (err) {
      console.error("Failed to sync campus FCM token:", err);
    }
  }
);
