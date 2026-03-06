import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {Constants} from "../constants";

export const getQueries = onCall(async (request) => {
  // Auth guard
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Please log in to continue.");
  }

  const uid = request.auth.uid;
  const db = admin.firestore();
  const startAfterId = request.data?.startAfter as string | undefined;

  // Fetch user's campus
  const userSnap = await db.collection("users").doc(uid).get();
  if (!userSnap.exists) {
    throw new HttpsError(
      "not-found",
      "Account Data not found. Please contact support."
    );
  }

  // profile complete check
  if (!userSnap.data()?.profileComplete) {
    throw new HttpsError(
      "failed-precondition",
      "Please complete your profile to continue."
    );
  }

  const campus = userSnap.data()?.campus as string | undefined;
  if (!campus) {
    throw new HttpsError(
      "failed-precondition",
      "No campus set. Please check your profile or contact support."
    );
  }

  // Build query
  let q = db
    .collection("queries")
    .where("campus", "==", campus)
    .orderBy("postedAt", "desc")
    .limit(Constants.fetchLimit);

  if (startAfterId) {
    const cursorSnap = await db.collection("queries").doc(startAfterId).get();
    if (!cursorSnap.exists) {
      // if cursor was deleted, silent return
      return {queries: []};
    }
    q = q.startAfter(cursorSnap);
  }

  // Execute & return
  const snapshot = await q.get();

  return {
    queries: snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
      postedAt: (doc.data().postedAt as admin.firestore.Timestamp).toMillis(),
    })),
  };
});
