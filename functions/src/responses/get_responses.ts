import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {Constants} from "../constants";

/** Fetches paginated responses for a query. */
export const getResponses = onCall({maxInstances: 2}, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Please log in to continue.");
  }

  if (!request.auth.token.email_verified) {
    throw new HttpsError(
      "failed-precondition",
      "Please verify your email to continue.");
  }

  const db = admin.firestore();
  const {queryId, startAfter} = request.data;

  if (!queryId) {
    throw new HttpsError(
      "invalid-argument",
      "Query ID is missing, please try again!");
  }

  const queryRef = db.collection("queries").doc(queryId);
  const querySnap = await queryRef.get();
  if (!querySnap.exists) {
    throw new HttpsError("not-found", "Query not found.");
  }

  let q = queryRef
    .collection("responses")
    .orderBy("postedAt", "desc")
    .limit(Constants.fetchLimit);

  if (startAfter) {
    const cursorSnap = await queryRef
      .collection("responses").doc(startAfter).get();
    if (!cursorSnap.exists) return {responses: []};
    q = q.startAfter(cursorSnap);
  }

  const snapshot = await q.get();

  return {
    responses: snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
      postedAt: (doc.data().postedAt as admin.firestore.Timestamp).toMillis(),
    })),
  };
});
