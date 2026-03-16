import 'package:in_app_update/in_app_update.dart';

class UpdateChecker {
  static Future<void> check() async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability != UpdateAvailability.updateAvailable) return;

      // Start flexible update — shows Play Store bottom sheet
      final result = await InAppUpdate.startFlexibleUpdate();

      // Download accepted — install
      if (result == AppUpdateResult.success) {
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (_) {
      // Silently fail on debug/non-Play builds
    }
  }
}
