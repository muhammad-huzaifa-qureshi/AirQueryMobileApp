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
export {deleteAccount} from "./users/delete_account";
export {updateProfile} from "./users/update_profile";
// export triggers
export {onQueryCreated} from "./triggers/on_query_created";
export {onQueryDeleted} from "./triggers/on_query_deleted";
export {onResponseCreated} from "./triggers/on_response_created";
export {onUserUpdated} from "./triggers/on_user_updated";
