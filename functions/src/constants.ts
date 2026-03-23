/** Application-wide constants */
export class Constants {
  // query len
  static readonly minQueryLen = 10;
  static readonly maxQueryLen = 500;

  // response len
  static readonly minRespLen = 1;
  static readonly maxRespLen = 500;

  // rate limiting
  static readonly nameChangeCooldownDays = 2;
  static readonly nameChangeCooldownMS =
    this.nameChangeCooldownDays * 24 * 60 * 60 * 1000;
  static readonly maxQueriesPerDayPerUser = 2;
}
