import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {Constants} from "../constants";

export const updateProfile = onCall(async (request) => {
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
  if (!name && !semester && !campus) {
    throw new HttpsError(
      "invalid-argument",
      "Please provide at least one field to update."
    );
  }

  // name min. 3 chars allowed
  if (name.length < Constants.nameMinChars) {
    throw new HttpsError(
      "invalid-argument",
      `Name must contain at least ${Constants.nameMinChars} characters!`
    );
  }

  // Validate semester range
  if (semester !== undefined) {
    const semNum = parseInt(semester, 10);
    if (isNaN(semNum) || semNum < 1 || semNum > 8) {
      throw new HttpsError(
        "invalid-argument",
        "Semester must be between 1 and 8."
      );
    }
  }

  // Validate campus
  if (campus !== undefined && !Constants.campuses.includes(campus)) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid campus selected."
    );
  }

  // Build update map with only provided fields
  const updates: Record<string, unknown> = {};

  if (name) updates.name = name;
  if (semester) updates.semester = semester;
  if (campus) updates.campus = campus;
  updates.profileComplete = true;

  // Create or update — merge handles both cases
  await db.collection("users").doc(uid).set(updates, {merge: true});

  return {success: true};
});
