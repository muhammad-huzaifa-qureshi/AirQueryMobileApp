import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

/** Fetches public profile of another user by uid. */
export const getOtherUserProfile = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Please log in to continue.");
  }

  if (!request.auth.token.email_verified) {
    throw new HttpsError(
      "failed-precondition",
      "Please verify your email to continue.");
  }

  const {uid} = request.data;

  if (!uid) {
    throw new HttpsError("invalid-argument", "User ID is required.");
  }

  const db = admin.firestore();
  const userSnap = await db.collection("users").doc(uid).get();

  if (!userSnap.exists) {
    throw new HttpsError("not-found", "User not found.");
  }

  const data = userSnap.data();
  if (!data) {
    throw new HttpsError("not-found", "User data not found.");
  }

  return {
    uid,
    name: data.name ?? "",
    campus: data.campus ?? "",
    semester: data.semester ?? "",
    queriesPosted: data.queriesPosted ?? 0,
    queriesAnswered: data.queriesAnswered ?? 0,
    queriesResolved: data.queriesResolved ?? 0,
  };
});
