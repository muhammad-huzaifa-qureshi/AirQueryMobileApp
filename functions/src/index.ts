import * as admin from "firebase-admin";
import {setGlobalOptions} from "firebase-functions/v2";

admin.initializeApp();
setGlobalOptions({maxInstances: 2, region: "asia-south1"});

// export functions
export {getQueries} from "./queries/get_queries";
export {getProfile} from "./users/get_profile";
