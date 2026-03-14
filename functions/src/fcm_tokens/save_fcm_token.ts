import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const saveFcmToken = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Please log in to continue.");
  }

  if (!request.auth.token.email_verified) {
    throw new HttpsError(
      "failed-precondition",
      "Please verify your email to continue.");
  }

  const {token} = request.data;
  if (!token) {
    throw new HttpsError("invalid-argument", "Token is required.");
  }

  await admin.firestore()
    .collection("users")
    .doc(request.auth.uid)
    .set({fcmToken: token}, {merge: true});

  return {success: true};
});
