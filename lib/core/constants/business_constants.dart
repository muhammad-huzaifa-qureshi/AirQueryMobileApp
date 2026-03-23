class BusinessConstants {
  static const String githubRepoLink =
      "https://github.com/muhammad-huzaifa-qureshi/AirQueryMobileApp";
  static const String authorLinkedin =
      "https://www.linkedin.com/in/muhammad-huzaifa-qureshi/";
  static const String privacyPolicy =
      "https://sites.google.com/view/air-query-privacy-policy";

  // password policy
  static const minPassChars = 8;
  static const maxPassChars = 32;

  // authentication
  static const resendCooldownSeconds = 60;
  static const auEmailDomain = '@students.au.edu.pk';
  static const timerTickSeconds = 2;

  // user full name
  static const nameMinChars = 3;
  static const nameMaxChars = 30;

  // query len
  static const minQueryLen = 10;
  static const maxQueryLen = 500;

  // response len
  static const minResponseLen = 1;
  static const maxResponseLen = 500;

  // rate limiting
  static const nameChangeCooldownDays = 2;
  static const maxQueriesPerDayPerUser = 2;
  static const maxResponsesPerDayPerUser = 50;

  // pagination (keep them n sync with FIREBASE RULES)
  static const queryFetchLimit = 10;
  static const responseFetchLimit = 10;
}
