/** Application-wide constants */
export class Constants {
  static readonly fetchLimit = 10;

  // query len
  static readonly minQueryLen = 10;
  static readonly maxQueryLen = 500;

  // response len
  static readonly minRespLen = 1;
  static readonly maxRespLen = 100;

  // rate limiting
  static readonly nameChangeCooldownDays = 5;
  static readonly nameChangeCooldownMS =
    this.nameChangeCooldownDays * 24 * 60 * 60 * 1000;
}
