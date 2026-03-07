import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const updateProfile = onCall(async (request) => {
  // Auth guard
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Please log in to continue.");
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

  // Build update map with only provided fields
  const updates: Record<string, string> = {};
  if (name) updates.name = name;
  if (semester) updates.semester = semester;
  if (campus) updates.campus = campus;

  // Create or update — merge handles both cases
  await db.collection("users").doc(uid).set(updates, {merge: true});

  return {success: true};
});
