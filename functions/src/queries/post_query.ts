import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {Constants} from "../constants";

/** Posts a new query and increments user and platform counters atomically. */
export const postQuery = onCall(
  {maxInstances: 1, enforceAppCheck: true},
  async (request) => {
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
    const trimmedDescription = description.trim();

    // Validate
    if (trimmedDescription === "") {
      throw new HttpsError(
        "invalid-argument",
        "Please provide a description for your query."
      );
    }

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

    const campus = postToAll ? "All" : userData.campus;

    const queryRef = db.collection("queries").doc();
    const userRef = db.collection("users").doc(uid);
    const statsRef = db.collection("platformStats").doc("global");

    await db.runTransaction(async (tx) => {
      tx.set(queryRef, {
        description: trimmedDescription,
        campus,
        postedBy: {uid, name: userData.name},
        postedAt: admin.firestore.FieldValue.serverTimestamp(),
        responseCount: 0,
      });
      tx.update(userRef, {
        queriesPosted: admin.firestore.FieldValue.increment(1),
      });
      tx.set(
        statsRef,
        {totalQueriesPosted: admin.firestore.FieldValue.increment(1)},
        {merge: true}
      );
    });

    // Notify campus users
    // ===============================
    // Send notifications (MULTICAST)
    try {
      let usersSnap;

      if (campus === "All") {
        usersSnap = await db.collection("users").get();
      } else {
        usersSnap = await db
          .collection("users")
          .where("campus", "==", campus)
          .get();
      }

      const tokens: string[] = [];

      usersSnap.forEach((doc) => {
        // exclude poster
        if (doc.id === uid) return;

        const token = doc.data().fcmToken as string | undefined;
        if (token) tokens.push(token);
      });

      if (tokens.length === 0) return {success: true};

      const notifBody =
        campus === "All" ?
          "A new query was posted for all campuses." :
          `A new query was posted for ${campus}.`;

      // FCM allows max 500 tokens per request
      const chunkSize = 500;
      for (let i = 0; i < tokens.length; i += chunkSize) {
        const chunk = tokens.slice(i, i + chunkSize);

        await admin.messaging().sendEachForMulticast({
          tokens: chunk,
          notification: {
            title: "New Query Posted!",
            body: notifBody,
          },
          data: {
            type: "new_query",
            queryId: queryRef.id,
            posterUid: uid,
          },
        });
      }
    } catch (e) {
      console.error("Notification failed:", e);
    }

    return {success: true};
  });
