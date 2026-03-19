import 'package:in_app_update/in_app_update.dart';

class UpdateChecker {
  static Future<void> check() async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability != UpdateAvailability.updateAvailable) return;

      await InAppUpdate.performImmediateUpdate();
    } catch (_) {}
  }
}