import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const postQuery = onCall(async (request) => {
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
  const {description, postToAll} = request.data;

  // Validate
  if (!description || description.trim() === "") {
    throw new HttpsError(
      "invalid-argument",
      "Please provide a description for your query."
    );
  }

  // Fetch user doc
  const userSnap = await db.collection("users").doc(uid).get();
  if (!userSnap.exists) {
    throw new HttpsError("not-found", "Please set up your profile first.");
  }

  const userData = userSnap.data();
  if (!userData?.profileComplete) {
    throw new HttpsError(
      "failed-precondition",
      "Please complete your profile to continue."
    );
  }

  // Build query doc
  const campus = postToAll ? "All" : userData.campus;

  await db.collection("queries").add({
    description: description.trim(),
    campus,
    postedBy: {uid, name: userData.name},
    postedAt: admin.firestore.FieldValue.serverTimestamp(),
    responseCount: 0,
  });

  // Increment counters
  await db.collection("users").doc(uid).update({
    queriesPosted: admin.firestore.FieldValue.increment(1),
  });
  await db.collection("platformStats").doc("global").set(
    {totalQueriesPosted: admin.firestore.FieldValue.increment(1)},
    {merge: true}
  );

  return {success: true};
});
