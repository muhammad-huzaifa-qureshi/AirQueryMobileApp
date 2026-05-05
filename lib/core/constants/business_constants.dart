class BusinessConstants {
  // version
  static const appCurrentVersion = "3.0.0";

  // Links
  static const String githubRepoLink =
      "https://github.com/muhammad-huzaifa-qureshi/AirQueryMobileApp";
  static const String devLinkedin =
      "https://www.linkedin.com/in/muhammad-huzaifa-qureshi/";
  static const String privacyPolicy =
      "https://sites.google.com/view/air-query-privacy-policy";
  static const String devEmail = "mailto:muhammadhuzaifaqureshi01@gmail.com";
  static const String appPlayStoreLink =
      "https://play.google.com/store/apps/details?id=com.hqapplications.airuniversity.airquery";
  static const String premiumApplicationLink =
      "https://forms.gle/TKLJMbbwJ5GTNrjG7";

  // FCM topics
  static const String fcmTopicAllUsers = "all_users";

  // password policy
  static const minPassChars = 8;
  static const maxPassChars = 32;

  // authentication
  static const resendCooldownSeconds = 60;
  static const timerTickSeconds = 2;

  // premium
  static const premiumActualPrice = 500;
  static const premiumDiscountedPricePKR = 99;

  // user profile
  static const nameMinChars = 3;
  static const nameMaxChars = 30;
  static const aboutMaxChars = 150;
  static const List<String> roles = [
    "AU Student",
    "AU Staff",
    "Alumnus",
    "Explorer",
  ];

  // query len
  static const minQueryLen = 10;
  static const maxQueryLen = 2000;

  // response len
  static const minResponseLen = 1;
  static const maxResponseLen = 500;

  // rate limiting
  static const profileUpdateCooldownDays = 2;
  static const maxQueriesPerDayPerUser = 1;
  static const maxResponsesPerDayPerUser = 50;

  // pagination (keep them n sync with FIREBASE RULES)
  static const queryFetchLimit = 10;
  static const responseFetchLimit = 10;

  // query image uploading
  static const maxQueryImageSizeMB = 5;
  static const maxQueryImageWidth = 1024.00;
  static const queryImageQuality = 70;

  // query expiry
  static const resolvedQueryTTLDays = 7;
}
