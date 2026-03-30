import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {Constants} from "../constants";

/** Posts a response to a query and increments counters atomically. */
export const postResponse = onCall(
  {maxInstances: 1, enforceAppCheck: true},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Please log in to continue.");
    }
    if (!request.auth.token.email_verified) {
      throw new HttpsError(
        "failed-precondition",
        "Please verify your email to continue."
      );
    }

    const uid = request.auth.uid;
    const db = admin.firestore();
    const {queryId, description, mentionedUid, mentionedName} = request.data;

    if (!queryId) {
      throw new HttpsError(
        "invalid-argument",
        "Query ID is missing, please try again!"
      );
    }

    const trimmedDescription = (description as string).trim();

    if (trimmedDescription.length < Constants.minRespLen) {
      throw new HttpsError(
        "invalid-argument",
        `Response must be at least ${Constants.minRespLen} characters.`
      );
    }
    if (trimmedDescription.length > Constants.maxRespLen) {
      throw new HttpsError(
        "invalid-argument",
        `Response must not exceed ${Constants.maxRespLen} characters.`
      );
    }

    // Fetch query + user in parallel
    const [querySnap, userSnap, rateLimitSnap] = await Promise.all([
      db.collection("queries").doc(queryId).get(),
      db.collection("users").doc(uid).get(),
      db.collection("users").doc(uid)
        .collection("rateLimits").doc("limits").get(),
    ]);

    if (!querySnap.exists) {
      throw new HttpsError("not-found", "Query not found.");
    }

    if (!userSnap.exists) {
      throw new HttpsError("not-found", "User not found.");
    }

    // Rate limit check
    const rateLimitData = rateLimitSnap.data();
    const now = Date.now();
    const lastPostedAt =
      rateLimitData?.responseLastPostedAt?.toMillis() ?? 0;
    const dailyCount = rateLimitData?.responseDailyCount ?? 0;
    const isSameDay =
      new Date(now).toDateString() ===
      new Date(lastPostedAt).toDateString();
    const currentCount = isSameDay ? dailyCount : 0;

    if (currentCount >= Constants.maxResponsesPerDayPerUser) {
      throw new HttpsError(
        "resource-exhausted",
        `You have already posted ${Constants.maxResponsesPerDayPerUser} ` +
        "responses today. Please try again tomorrow."
      );
    }

    const userName = userSnap.data()?.name as string ?? "";

    // Validate mention data
    let finalMentionedUid: string | null = null;
    let finalMentionedName: string | null = null;

    if (
      mentionedUid &&
      typeof mentionedUid === "string" &&
      mentionedUid.trim() !== "" &&
          mentionedUid !== uid &&
      mentionedName &&
      typeof mentionedName === "string" &&
      mentionedName.trim() !== ""
    ) {
      finalMentionedUid = mentionedUid.trim();
      finalMentionedName = mentionedName.trim();
    }

    const responseRef = querySnap.ref.collection("responses").doc();
    const queryRef = querySnap.ref;
    const userRef = db.collection("users").doc(uid);
    const statsRef = db.collection("platformStats").doc("global");
    const rateLimitRef = db.collection("users").doc(uid)
      .collection("rateLimits").doc("limits");

    await db.runTransaction(async (tx) => {
      tx.set(responseRef, {
        description: trimmedDescription,
        postedBy: {uid, name: userName},
        postedAt: admin.firestore.FieldValue.serverTimestamp(),
        mentionedUid: finalMentionedUid,
        mentionedName: finalMentionedName,
      });
      tx.update(queryRef, {
        responseCount: admin.firestore.FieldValue.increment(1),
      });
      tx.update(statsRef, {
        totalResponses: admin.firestore.FieldValue.increment(1),
      });
      tx.update(userRef, {
        responsesPosted: admin.firestore.FieldValue.increment(1),
      });
      tx.set(
        rateLimitRef,
        {
          responseLastPostedAt: admin.firestore.FieldValue.serverTimestamp(),
          responseDailyCount: currentCount + 1,
        },
        {merge: true}
      );
    });

    return {success: true};
  });
