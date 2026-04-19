import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {Constants} from "../constants";

/** Posts a new query and increments user and platform counters atomically. */
export const postQuery = onCall(
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
    const {description, postToAll} = request.data;
    const trimmedDescription = (description as string).trim();

    // Validate description
    if (trimmedDescription.length < Constants.minQueryLen) {
      throw new HttpsError(
        "invalid-argument",
        `Query must be at least ${Constants.minQueryLen} characters.`
      );
    }
    if (trimmedDescription.length > Constants.maxQueryLen) {
      throw new HttpsError(
        "invalid-argument",
        `Query must be less than ${Constants.maxQueryLen} characters.`
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

    // Check rate limit
    const rateLimitRef = db
      .collection("users")
      .doc(uid)
      .collection("rateLimits")
      .doc("limits");

    const rateLimitSnap = await rateLimitRef.get();
    const rateLimitData = rateLimitSnap.data();

    const now = Date.now();
    const lastPostedAt = rateLimitData?.queryLastPostedAt?.toMillis() ?? 0;
    const dailyCount = rateLimitData?.queryDailyCount ?? 0;

    // Reset count if last post was on a different day
    const isSameDay =
      new Date(now).toDateString() === new Date(lastPostedAt).toDateString();
    const currentCount = isSameDay ? dailyCount : 0;

    if (currentCount >= Constants.maxQueriesPerDayPerUser) {
        const max = Constants.maxQueriesPerDayPerUser
      throw new HttpsError(
        "resource-exhausted",
        `You have already posted ${max} ` +
        `${max === 1? "query" : "queries"} today. Try again tomorrow.`
      );
    }

    const campus = postToAll ? "All" : userData.campus;
    const queryRef = db.collection("queries").doc();
    const userRef = db.collection("users").doc(uid);
    const statsRef = db.collection("platformStats").doc("global");

    // Atomic transaction + rate limit update
    await db.runTransaction(async (tx) => {
      tx.set(queryRef, {
        description: trimmedDescription,
        campus,
        postedBy: {uid, name: userData.name},
        postedAt: admin.firestore.FieldValue.serverTimestamp(),
        responseCount: 0,
        isResolved: false,
      });
      tx.update(userRef, {
        queriesPosted: admin.firestore.FieldValue.increment(1),
      });
      tx.set(
        statsRef,
        {totalQueriesPosted: admin.firestore.FieldValue.increment(1)},
        {merge: true}
      );
      // Update rate limit inside transaction
      tx.set(
        rateLimitRef,
        {
          queryLastPostedAt: admin.firestore.FieldValue.serverTimestamp(),
          queryDailyCount: currentCount + 1,
        },
        {merge: true}
      );
    });

    return {success: true};
  });
