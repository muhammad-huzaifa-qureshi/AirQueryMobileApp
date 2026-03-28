import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {batchUpdateName} from "../utils/batch_update_name";
import {Constants} from "../constants";

export const updateProfile = onCall(
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
    const {name, campus, semester} = request.data;

    if (
      typeof name !== "string" ||
      typeof campus !== "string" ||
      typeof semester !== "string"
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid profile data."
      );
    }

    // CAMPUS VALIDATION
    if (!Constants.campuses.includes(campus)) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid campus selected."
      );
    }

    // SEMESTER VALIDATION
    const semesterNumber = Number(semester);

    if (
      !Number.isInteger(semesterNumber) ||
      semesterNumber < 1 ||
      semesterNumber > 8
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Semester must be between 1 and 8."
      );
    }

    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);
    const rateLimitRef =
      userRef.collection("rateLimits").doc("limits");

    const [userSnap, rateSnap] = await Promise.all([
      userRef.get(),
      rateLimitRef.get(),
    ]);

    if (!userSnap.exists) {
      throw new HttpsError("not-found", "User not found.");
    }

    const userData = userSnap.data();
    if (!userData) {
      throw new HttpsError("not-found", "User data not found.");
    }
    const user = userData;

    const oldName = user.name ?? "";
    const oldCampus = user.campus ?? "";

    const nameChanged = oldName !== name;
    const campusChanged = oldCampus !== campus;
    const semesterChanged = user.semester !== semester;

    // PROFILE COOLDOWN
    if (!(nameChanged || campusChanged || semesterChanged)) {
      return {success: true};
    }

    if (rateSnap.exists) {
      const lastUpdated =
        rateSnap.data()?.profileLastUpdated?.toMillis?.() ?? 0;

      const elapsed = Date.now() - lastUpdated;

      if (elapsed < Constants.profileUpdateCooldownMS) {
        const daysRemaining = Math.ceil(
          (Constants.profileUpdateCooldownMS - elapsed) / (24 * 60 * 60 * 1000)
        );
        const message =
          `You can update your profile again in ${daysRemaining} ` +
          `day${daysRemaining > 1 ? "s" : ""}.`;

        throw new HttpsError("resource-exhausted", message);
      }
    }

    // update user profile
    await userRef.set({
      name,
      campus,
      semester,
      profileComplete: true,
    }, {merge: true});

    // propogate name
    if (nameChanged) {
      const [querySnap, responseSnap] = await Promise.all([
        db.collection("queries")
          .where("postedBy.uid", "==", uid)
          .get(),

        db.collectionGroup("responses")
          .where("postedBy.uid", "==", uid)
          .get(),
      ]);

      await Promise.all([
        batchUpdateName(db, querySnap.docs, name),
        batchUpdateName(db, responseSnap.docs, name),
      ]);
    }

    // MOVE FCM TOKEN (CAMPUS CHANGE)
    if (campusChanged) {
      const tokenSnap = await userRef
        .collection("private")
        .doc("fcmToken")
        .get();

      const token = tokenSnap.data()?.token;

      if (token) {
        const batch = db.batch();

        // remove from old campus
        batch.set(
          db.collection("fcmTokens").doc(oldCampus),
          {[uid]: admin.firestore.FieldValue.delete()},
          {merge: true}
        );

        // add to new campus
        batch.set(
          db.collection("fcmTokens").doc(campus),
          {[uid]: token},
          {merge: true}
        );

        await batch.commit();
      }
    }

    // UPDATE RATE LIMIT
    if (nameChanged || campusChanged || semesterChanged) {
      await rateLimitRef.set({
        profileLastUpdated:
          admin.firestore.FieldValue.serverTimestamp(),
      }, {merge: true});
    }

    return {success: true};
  }
);
