import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {Constants} from "../constants";

/** Posts a response to a query and increments responseCount. */
export const postResponse = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Please log in to continue.");
  }

  if (!request.auth.token.email_verified) {
    throw new HttpsError("failed-precondition", "Please verify your email to continue.");
  }

  const uid = request.auth.uid;
  const db = admin.firestore();

  const {queryId, description} = request.data;

  if (!queryId) {
    throw new HttpsError("invalid-argument", "Query ID is required.");
  }

  if (!description || description.trim().length < Constants.minRespLen) {
    throw new HttpsError(
      "invalid-argument",
      `Response must be at least ${Constants.minRespLen} characters.`
    );
  }

  if (description.trim().length > Constants.maxRespLen) {
    throw new HttpsError(
      "invalid-argument",
      `Response must not exceed ${Constants.maxRespLen} characters.`
    );
  }

  // Check query exists
  const queryRef = db.collection("queries").doc(queryId);
  const querySnap = await queryRef.get();
  if (!querySnap.exists) {
    throw new HttpsError("not-found", "Query not found.");
  }

  // Fetch user info
  const userSnap = await db.collection("users").doc(uid).get();
  if (!userSnap.exists) {
    throw new HttpsError("not-found", "User not found.");
  }

  const userName = userSnap.data()?.name as string;

  // Write response + increment count atomically
  const responseRef = queryRef.collection("responses").doc();
  const statsRef = db.collection("platformStats").doc("global");
  const userRef = db.collection("users").doc(uid);

  await db.runTransaction(async (tx) => {
    tx.set(responseRef, {
      description: description.trim(),
      postedBy: {uid, name: userName},
      postedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.update(queryRef, {
      responseCount: admin.firestore.FieldValue.increment(1),
    });
    tx.update(statsRef, {
        totalResponses: admin.firestore.FieldValue.increment(1),
    })
    tx.update(userRef, {
        queriesAnswered: admin.firestore.FieldValue.increment(1),
    })
  });

  return {success: true};
});