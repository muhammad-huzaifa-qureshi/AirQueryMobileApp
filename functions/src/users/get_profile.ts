import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const getProfile = onCall({maxInstances: 2}, async (request) => {
  // Auth guard
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Please log in to continue.");
  }

  // Email verification check
  if (!request.auth.token.email_verified) {
    throw new HttpsError(
      "failed-precondition",
      "Please verify your email to continue."
    );
  }

  const uid = request.auth.uid;
  const db = admin.firestore();

  // Fetch user doc
  const userSnap = await db.collection("users").doc(uid).get();

  if (!userSnap.exists) {
    // No doc yet — return empty profile
    return {
      uid,
      name: "",
      campus: "",
      semester: "",
      queriesPosted: 0,
      queriesAnswered: 0,
      queriesResolved: 0,
      profileComplete: false,
    };
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
