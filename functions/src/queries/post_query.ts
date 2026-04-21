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

    const {description, postToAll, base64Image} = request.data;
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

    // Rate limit
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

    const isSameDay =
      new Date(now).toDateString() === new Date(lastPostedAt).toDateString();

    const currentCount = isSameDay ? dailyCount : 0;

    if (currentCount >= Constants.maxQueriesPerDayPerUser) {
      const max = Constants.maxQueriesPerDayPerUser;
      throw new HttpsError(
        "resource-exhausted",
        `You have already posted ${max} ${max === 1 ? "query" : "queries"} ` +
        "today. Try again tomorrow."
      );
    }

    const campus = postToAll ? "All" : userData.campus;

    const queryRef = db.collection("queries").doc();
    const userRef = db.collection("users").doc(uid);
    const statsRef = db.collection("platformStats").doc("global");

    let imagePath: string | null = null;

    if (base64Image?.trim()) {
      const match = base64Image.match(
        /^data:(image\/[a-zA-Z0-9.+-]+);base64,/
      );

      let mimeType = "image/jpeg";
      let rawBase64 = base64Image;

      if (match) {
        mimeType = match[1];
        rawBase64 = base64Image.replace(/^data:.*;base64,/, "");
      }

      const sizeInMB =
        Buffer.byteLength(rawBase64, "base64") / 1024 / 1024;

      if (sizeInMB > Constants.maxQueryImageSizeMB) {
        throw new HttpsError(
          "invalid-argument",
          `Image must be under ${Constants.maxQueryImageSizeMB} MB.`
        );
      }

      let buffer: Buffer;
      try {
        buffer = Buffer.from(rawBase64, "base64");
      } catch {
        throw new HttpsError("invalid-argument", "Invalid image format.");
      }

      let imageExt: string;
      let contentType: string;

      switch (mimeType) {
      case "image/png":
        imageExt = "png";
        contentType = "image/png";
        break;

      case "image/jpeg":
      case "image/jpg":
        imageExt = "jpg";
        contentType = "image/jpeg";
        break;

      case "image/webp":
        imageExt = "webp";
        contentType = "image/webp";
        break;

      case "image/heic":
      case "image/heif":
        imageExt = "heic";
        contentType = mimeType;
        break;

      default:
        throw new HttpsError(
          "invalid-argument",
          `Unsupported image type: ${mimeType}`
        );
      }

      const filePath = `queries/${uid}/${queryRef.id}.${imageExt}`;
      const file = admin.storage().bucket().file(filePath);

      await file.save(buffer, {
        metadata: {
          contentType,
        },
      });

      imagePath = filePath;
    }

    // Transaction
    await db.runTransaction(async (tx) => {
      tx.set(queryRef, {
        description: trimmedDescription,
        campus,
        postedBy: {
          uid,
          name: userData.name,
        },
        postedAt: admin.firestore.FieldValue.serverTimestamp(),
        responseCount: 0,
        isResolved: false,
        imagePath: imagePath ?? null,
      });

      tx.update(userRef, {
        queriesPosted: admin.firestore.FieldValue.increment(1),
      });

      tx.set(
        statsRef,
        {
          totalQueriesPosted: admin.firestore.FieldValue.increment(1),
        },
        {merge: true}
      );

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
  }
);
