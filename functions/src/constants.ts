/** Application-wide constants */
export class Constants {
  // insider roles (require @au.edu.pk email)
  static readonly insiderRoles = ["AU Student", "AU Staff"];

  // all selectable roles (Founder/etc. is excluded; set directly in Firestore)
  static readonly allowedRoles = [
    ...Constants.insiderRoles,
    "Alumnus",
    "Explorer",
  ];

  // email domain required for insider roles
  static readonly auEmailDomain = "au.edu.pk";

  // FCM topic for broadcasting new-query notifications to all users
  static readonly fcmTopicAllUsers = "all_users";

  // image size
  static readonly maxQueryImageSizeMB = 5;

  // query len
  static readonly minQueryLen = 10;
  static readonly maxQueryLen = 2000;

  // response len
  static readonly minRespLen = 1;
  static readonly maxRespLen = 500;

  // rate limiting
  static readonly profileUpdateCooldownDays = 2;
  static readonly profileUpdateCooldownMS =
    this.profileUpdateCooldownDays * 24 * 60 * 60 * 1000;

  static readonly maxQueriesPerDayPerUser = 1;
  static readonly maxResponsesPerDayPerUser = 50;

  // query expiry
  static readonly resolvedQueryTTLDays = 7;
}
