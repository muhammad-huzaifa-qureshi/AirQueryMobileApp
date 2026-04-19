/** Application-wide constants */
export class Constants {
  // campuses
  static readonly campuses = [
    "Islamabad E9 Campus",
    "Islamabad H11 Campus",
    "Multan Campus",
    "Kamra Campus",
    "Karachi Campus",
    "Kharian Campus",
    "Karachi Campus",
    "Bahu Campus",
    "Attock Campus"
  ];

  // query len
  static readonly minQueryLen = 10;
  static readonly maxQueryLen = 500;

  // response len
  static readonly minRespLen = 1;
  static readonly maxRespLen = 500;

  // rate limiting
  static readonly profileUpdateCooldownDays = 2;
  static readonly profileUpdateCooldownMS =
    this.profileUpdateCooldownDays * 24 * 60 * 60 * 1000;

  static readonly maxQueriesPerDayPerUser = 2;
  static readonly maxResponsesPerDayPerUser = 50;
}
