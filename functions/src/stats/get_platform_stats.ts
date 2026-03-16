import {onCall} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const getPlatformStats = onCall(
  {maxInstances: 1, enforceAppCheck: true},
  async () => {
    const db = admin.firestore();

    const snap = await db.collection("platformStats").doc("global").get();

    if (!snap.exists) {
      return {
        totalQueriesPosted: 0,
        totalQueriesResolved: 0,
        totalResponses: 0,
      };
    }

    const data = snap.data();
    if (!data) {
      return {
        totalQueriesPosted: 0,
        totalQueriesResolved: 0,
        totalResponses: 0,
      };
    }

    return {
      totalQueriesPosted: data.totalQueriesPosted ?? 0,
      totalQueriesResolved: data.totalQueriesResolved ?? 0,
      totalResponses: data.totalResponses ?? 0,
    };
  });
