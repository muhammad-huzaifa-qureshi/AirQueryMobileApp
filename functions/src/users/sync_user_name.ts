import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {batchUpdateName} from "../utils/batch_update_name";
import {Constants} from "../constants";

export const syncUserName = onCall(
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
    const {name} = request.data;

    if (!name || typeof name !== "string" || name.trim().length === 0) {
      throw new HttpsError("invalid-argument", "Name is required.");
    }

    const db = admin.firestore();

    const rateLimitRef = db
      .collection("users")
      .doc(uid)
      .collection("rateLimits")
      .doc("limits");

    const rateLimitSnap = await rateLimitRef.get();

    if (rateLimitSnap.exists) {
      const lastChanged = rateLimitSnap
        .data()?.nameLastChanged?.toMillis() ?? 0;

      const now = Date.now();
      const elapsed = now - lastChanged;

      if (elapsed < Constants.nameChangeCooldownMS) {
        const daysRemaining = Math.ceil(
          (Constants.nameChangeCooldownMS - elapsed) / (24 * 60 * 60 * 1000)
        );
        const message =
          `You can change your name again in ${daysRemaining} ` +
          `day${daysRemaining > 1 ? "s" : ""}.`;

        throw new HttpsError("resource-exhausted", message);
      }
    }

    const [querySnap, responseSnap] = await Promise.all([
      db.collection("queries").where("postedBy.uid", "==", uid).get(),
      db.collectionGroup("responses").where("postedBy.uid", "==", uid).get(),
    ]);

    // Write name to user doc + propagate to queries/responses
    await Promise.all([
      db.collection("users").doc(uid).update({name}),
      batchUpdateName(db, querySnap.docs, name),
      batchUpdateName(db, responseSnap.docs, name),
      // update rate limit doc
      rateLimitRef.set(
        {nameLastChanged: admin.firestore.FieldValue.serverTimestamp()},
        {merge: true}
      ),
    ]);

    return {success: true};
  });
