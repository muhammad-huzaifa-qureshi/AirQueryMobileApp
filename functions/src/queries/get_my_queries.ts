import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {Constants} from "../constants";

export const getMyQueries = onCall({maxInstances: 2}, async (request) => {
  // Auth guard
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Please log in to continue.");
  }
  // Email verification check
  if (!request.auth.token.email_verified) {
    throw new HttpsError(
      "failed-precondition",
      "Please verify your email to continue.");
  }

  const uid = request.auth.uid;
  const db = admin.firestore();
  const startAfterId = request.data?.startAfter as string | undefined;

  let q = db
    .collection("queries")
    .where("postedBy.uid", "==", uid)
    .orderBy("postedAt", "desc")
    .limit(Constants.fetchLimit);

  if (startAfterId) {
    const cursorSnap = await db.collection("queries").doc(startAfterId).get();
    if (!cursorSnap.exists) return {queries: []};
    q = q.startAfter(cursorSnap);
  }

  const snapshot = await q.get();

  return {
    queries: snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
      postedAt: (doc.data().postedAt as admin.firestore.Timestamp).toMillis(),
    })),
  };
});
