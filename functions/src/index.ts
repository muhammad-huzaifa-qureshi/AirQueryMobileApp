import * as admin from "firebase-admin";
import {setGlobalOptions} from "firebase-functions/v2";

admin.initializeApp();
setGlobalOptions({maxInstances: 2, region: "asia-south1"});

// export functions
export {getQueries} from "./queries/get_queries";
export {getProfile} from "./users/get_profile";
export {updateProfile} from "./users/update_profile";
export {getPlatformStats} from "./stats/get_platform_stats";
export {postQuery} from "./queries/post_query";
export {deleteQuery} from "./queries/delete_query";
export {resolveQuery} from "./queries/resolve_query";
export {getMyQueries} from "./queries/get_my_queries";
export {postResponse} from "./responses/post_response";
export {deleteResponse} from "./responses/delete_response";
export {getResponses} from "./responses/get_responses";
