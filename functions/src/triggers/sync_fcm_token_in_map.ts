import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

// Syncs user FCM token to campus-level map
// on any change in private fcmToken doc
export const syncFcmTokenInMap = onDocumentWritten(
  "users/{uid}/private/fcmToken",
  async (event) => {
    const uid = event.params.uid;
    const newToken = event.data?.after?.data()?.token as string | undefined;
    const db = admin.firestore();

    try {
      const userSnap = await db.collection("users").doc(uid).get();
      const campus = userSnap.data()?.campus as string | undefined;
      if (!campus) return;

      const campusDocRef = db.collection("fcmTokens").doc(campus);

      if (!newToken) {
        await campusDocRef.set(
          {[uid]: admin.firestore.FieldValue.delete()},
          {merge: true}
        );
      } else {
        await campusDocRef.set({[uid]: newToken}, {merge: true});
      }
    } catch (err) {
      console.error("Failed to sync campus FCM token:", err);
    }
  }
);
