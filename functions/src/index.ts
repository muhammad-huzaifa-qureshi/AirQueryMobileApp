import * as admin from "firebase-admin";
import {setGlobalOptions} from "firebase-functions/v2";

admin.initializeApp();
setGlobalOptions({region: "asia-south1"});

// export functions
export {postQuery} from "./queries/post_query";
export {deleteQuery} from "./queries/delete_query";
export {resolveQuery} from "./queries/resolve_query";
export {postResponse} from "./responses/post_response";
export {deleteResponse} from "./responses/delete_response";
export {getResponses} from "./responses/get_responses";
export {deleteAccount} from "./users/delete_account";
export {syncUserName} from "./users/sync_user_name";
