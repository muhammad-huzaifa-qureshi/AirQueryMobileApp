import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {batchUpdatePostedBy} from "../utils/batch_update_posted_by";
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
    const {name, role, about} = request.data;

    // TYPE VALIDATION
    if (
      typeof name !== "string" ||
      typeof role !== "string" ||
      typeof about !== "string"
    ) {
      throw new HttpsError("invalid-argument", "Invalid profile data.");
    }

    // ROLE VALIDATION (Founder/etc. is excluded — set directly in Firestore)
    if (!Constants.allowedRoles.includes(role)) {
      throw new HttpsError("invalid-argument", "Invalid role selected.");
    }

    // EMAIL-DOMAIN CHECK for insider roles
    const email = request.auth.token.email ?? "";
    if (
      Constants.insiderRoles.includes(role) &&
      !email.endsWith(`${Constants.auEmailDomain}`)
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Only @au.edu.pk email addresses can select AU Student" +
        " or AU Staff roles."
      );
    }

    const isInsider = Constants.insiderRoles.includes(role);

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
        role: "",
        about: "",
        isInsider: false,
        isPremium: false,
        queriesPosted: 0,
        responsesPosted: 0,
        queriesResolved: 0,
        profileComplete: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    const user = isNewUser ? {} : (userSnap.data() ?? {});

    const oldName = user.name ?? "";
    const oldRole = user.role ?? "";
    const oldAbout = user.about ?? "";

    const nameChanged = oldName !== name;
    const roleChanged = oldRole !== role;
    const aboutChanged = oldAbout !== about;
    const isInsiderChanged = (user.isInsider ?? false) !== isInsider;

    // NO CHANGES
    if (!(nameChanged || roleChanged || aboutChanged)) {
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
      role,
      about,
      isInsider,
      profileComplete: true,
    }, {merge: true});

    // PROPAGATE POSTED BY INFO
    if ((nameChanged || isInsiderChanged) && !isNewUser) {
      const fields: Partial<{
          name: string;
          isInsider: boolean;
          isPremium: boolean
         }> = {};
      if (nameChanged) fields.name = name;
      if (isInsiderChanged) fields.isInsider = isInsider;

      const [querySnap, responseSnap] = await Promise.all([
        db.collection("queries")
          .where("postedBy.uid", "==", uid)
          .get(),
        db.collectionGroup("responses")
          .where("postedBy.uid", "==", uid)
          .get(),
      ]);

      await Promise.all([
        batchUpdatePostedBy(db, querySnap.docs, fields),
        batchUpdatePostedBy(db, responseSnap.docs, fields),
      ]);
    }

    // UPDATE RATE LIMIT
    await rateLimitRef.set({
      profileLastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    }, {merge: true});

    return {success: true};
  }
);
