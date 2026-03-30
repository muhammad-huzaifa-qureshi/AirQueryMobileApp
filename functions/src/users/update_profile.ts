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
      throw new HttpsError("invalid-argument", "Invalid profile data.");
    }

    // CAMPUS VALIDATION
    if (!Constants.campuses.includes(campus)) {
      throw new HttpsError("invalid-argument", "Invalid campus selected.");
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
    const rateLimitRef = userRef.collection("rateLimits").doc("limits");

    const [userSnap, rateSnap] = await Promise.all([
      userRef.get(),
      rateLimitRef.get(),
    ]);

    // CREATE USER DOC IF NOT EXISTS (new user)
    const isNewUser = !userSnap.exists;
    if (isNewUser) {
      await userRef.set({
        name: "",
        campus: "",
        semester: "",
        queriesPosted: 0,
        queriesAnswered: 0,
        queriesResolved: 0,
        profileComplete: false,
      });
    }

    const user = isNewUser ? {} : (userSnap.data() ?? {});

    const oldName = user.name ?? "";
    const oldCampus = user.campus ?? "";
    const oldSemester = user.semester ?? "";

    const nameChanged = oldName !== name;
    const campusChanged = oldCampus !== campus;
    const semesterChanged = oldSemester !== semester;

    // NO CHANGES
    if (!(nameChanged || campusChanged || semesterChanged)) {
      return {success: true};
    }

    // PROFILE COOLDOWN (skip for new users, they have no rate limit doc)
    if (!isNewUser && rateSnap.exists) {
      const lastUpdated =
        rateSnap.data()?.profileLastUpdated?.toMillis?.() ?? 0;
      const elapsed = Date.now() - lastUpdated;

      if (elapsed < Constants.profileUpdateCooldownMS) {
        const daysRemaining = Math.ceil(
          (Constants.profileUpdateCooldownMS - elapsed) /
            (24 * 60 * 60 * 1000)
        );
        const message =
          `You can update your profile again in ${daysRemaining} ` +
          `day${daysRemaining > 1 ? "s" : ""}.`;
        throw new HttpsError("resource-exhausted", message);
      }
    }

    // UPDATE USER PROFILE
    await userRef.set({
      name,
      campus,
      semester,
      profileComplete: true,
    }, {merge: true});

    // PROPAGATE NAME
    if (nameChanged && !isNewUser) {
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

        // remove from old campus only if it existed
        if (oldCampus !== "") {
          batch.set(
            db.collection("fcmTokens").doc(oldCampus),
            {[uid]: admin.firestore.FieldValue.delete()},
            {merge: true}
          );
        }

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
    await rateLimitRef.set({
      profileLastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    }, {merge: true});

    return {success: true};
  }
);
