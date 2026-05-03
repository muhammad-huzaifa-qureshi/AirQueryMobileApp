import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/business_constants.dart';

class AppExternalLaunchers {
  static Future<void> launchGithub() async {
    final uri = Uri.parse(BusinessConstants.githubRepoLink);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> launchAuthorLinkedin() async {
    final uri = Uri.parse(BusinessConstants.devLinkedin);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> launchPrivacyPolicy() async {
    final uri = Uri.parse(BusinessConstants.privacyPolicy);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> launchPlayStore() async {
    final uri = Uri.parse(BusinessConstants.appPlayStoreLink);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> launchPremiumApplication() async {
    final uri = Uri.parse(BusinessConstants.premiumApplicationLink);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> launchAuthorEmail() async {
    final uri = Uri.parse(BusinessConstants.devEmail);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static void shareApp() {
    const String message =
        "🙌 Check out this Mobile App designed for Air University Students only! Post and answer campus questions smartly and stay connected:"
        "\n${BusinessConstants.appPlayStoreLink}";

    SharePlus.instance.share(
      ShareParams(text: message, title: "Air Query Mobile App"),
    );
  }
}
