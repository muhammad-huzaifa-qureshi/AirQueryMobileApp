/** Application-wide constants */
export class Constants {
  static readonly fetchLimit = 10;

  // user full name
  static readonly nameMinChars = 3;
  static readonly nameMaxChars = 30;

  // query len
  static readonly minQueryLen = 10;
  static readonly maxQueryLen = 500;

  // response len
  static readonly minRespLen = 1;
  static readonly maxRespLen = 100;

  // campuses
  static readonly campuses = [
    "Islamabad E9 Campus",
    "Islamabad H11 Campus",
    "Multan Campus",
    "Kamra Campus",
    "Karachi Campus",
    "Kharian Campus",
    "Bahu Campus",
  ];
}
