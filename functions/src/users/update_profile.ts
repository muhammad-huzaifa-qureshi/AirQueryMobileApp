import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {Constants} from "../constants";

/**
 * Updates postedBy.name in batches of 499 to stay
 * within Firestore's 500 ops limit.
 * @param {admin.firestore.Firestore} db - Firestore instance
 * @param {admin.firestore.QueryDocumentSnapshot[]} docs - Docs to update
 * @param {string} name - New display name
 * @return {Promise<void>}
 */
async function batchUpdateName(
  db: admin.firestore.Firestore,
  docs: admin.firestore.QueryDocumentSnapshot[],
  name: string
): Promise<void> {
  const chunkSize = 499;
  for (let i = 0; i < docs.length; i += chunkSize) {
    const batch = db.batch();
    docs.slice(i, i + chunkSize).forEach((doc) =>
      batch.update(doc.ref, {"postedBy.name": name})
    );
    await batch.commit();
  }
}

/** Updates user profile fields
and syncs name changes across queries and responses. */
export const updateProfile = onCall({maxInstances: 1}, async (request) => {
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

  const {name, semester, campus} = request.data;

  // Validate: at least one field required
  if (name == null && semester == null && campus == null) {
    throw new HttpsError(
      "invalid-argument",
      "Please provide at least one field to update."
    );
  }

  // name checks
  if (name != null) {
    if (name.length < Constants.nameMinChars) {
      throw new HttpsError(
        "invalid-argument",
        `Name must contain at least ${Constants.nameMinChars} characters!`
      );
    }
    if (name.length > Constants.nameMaxChars) {
      throw new HttpsError(
        "invalid-argument",
        `Name must not exceed ${Constants.nameMaxChars} characters!`
      );
    }
  }

  // Validate semester range
  if (semester != null) {
    const semNum = parseInt(semester, 10);
    if (isNaN(semNum) || semNum < 1 || semNum > 8) {
      throw new HttpsError(
        "invalid-argument",
        "Semester must be between 1 and 8."
      );
    }
  }

  // Validate campus
  if (campus != null && !Constants.campuses.includes(campus)) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid campus selected."
    );
  }

  // Build update map
  const updates: Record<string, unknown> = {};
  if (name != null) updates.name = name;
  if (semester != null) updates.semester = semester;
  if (campus != null) updates.campus = campus;
  updates.profileComplete = true;

  // Save user profile
  await db.collection("users").doc(uid).set(updates, {merge: true});

  // Sync name across all queries and responses in parallel
  if (name != null) {
    const [querySnap, responseSnap] = await Promise.all([
      db.collection("queries").where("postedBy.uid", "==", uid).get(),
      db.collectionGroup("responses").where("postedBy.uid", "==", uid).get(),
    ]);

    await Promise.all([
      batchUpdateName(db, querySnap.docs, name),
      batchUpdateName(db, responseSnap.docs, name),
    ]);
  }

  return {success: true};
});
