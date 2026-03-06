import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const getProfile = onCall(async (request) => {
  // Auth guard
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Please log in to continue.");
  }

  const uid = request.auth.uid;
  const db = admin.firestore();

  // Fetch user doc
  const userSnap = await db.collection("users").doc(uid).get();

  if (!userSnap.exists) {
    throw new HttpsError(
      "not-found",
      "Account not found. Please contact support."
    );
  }

  const data = userSnap.data();
  if (!data) {
    throw new HttpsError("not-found", "Account data is empty.");
  }

  return {
    uid,
    name: data.name,
    campus: data.campus,
    semester: data.semester,
    queriesPosted: data.queriesPosted ?? 0,
    queriesAnswered: data.queriesAnswered ?? 0,
    queriesResolved: data.queriesResolved ?? 0,
    profileComplete: data.profileComplete ?? false,
  };
});
