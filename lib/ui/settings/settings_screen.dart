import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/widgets/confirm_dialog.dart';
import 'package:air_query/ui/auth/notifier/auth_notifier.dart';
import 'package:air_query/ui/settings/widgets/settings_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/business_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _launchGithub() async {
    final uri = Uri.parse(BusinessConstants.githubRepoLink);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchAuthorLinkedin() async {
    final uri = Uri.parse(BusinessConstants.authorLinkedin);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchPrivacyPolicy() async {
    final uri = Uri.parse(BusinessConstants.privacyPolicy);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchPlayStore() async {
    final uri = Uri.parse(BusinessConstants.appPlayStoreLink);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchAuthorEmail() async {
    final uri = Uri.parse(BusinessConstants.authorEmail);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _shareApp() {
    const String message =
        "🙌 Check out this Mobile App designed for Air University Students only! Post and answer campus questions smartly and stay connected:"
        "\n${BusinessConstants.appPlayStoreLink}";

    SharePlus.instance.share(
      ShareParams(text: message, title: "Air Query Mobile App"),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const .all(AppSizes.medium),
          child: Column(
            children: [
              // section 1
              SettingsCard(
                text: "About Us",
                icon: Icon(Icons.info_outline),
                onTap: () => Navigator.pushNamed(context, AppRoutes.about),
              ),
              SettingsCard(
                text: "Platform Stats",
                icon: Icon(Icons.leaderboard_outlined),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.platformStats),
              ),
              SettingsCard(
                text: "Privacy Policy",
                icon: Icon(Icons.privacy_tip_outlined),
                onTap: _launchPrivacyPolicy,
              ),
              SizedBox(height: AppSizes.vLarge),

              // section 2
              SettingsCard(
                text: "Email Support",
                icon: Icon(Icons.email_outlined),
                onTap: _launchAuthorEmail,
              ),
              SettingsCard(
                text: "GitHub Repository",
                icon: Icon(Icons.code),
                onTap: _launchGithub,
              ),
              SettingsCard(
                text: "Connect on Linkedin",
                icon: Icon(Icons.handshake_outlined),
                onTap: _launchAuthorLinkedin,
              ),

              // section 3
              SizedBox(height: AppSizes.vLarge),
              SettingsCard(
                text: "Rate on Play Store",
                icon: Icon(Icons.star_rate_rounded),
                onTap: _launchPlayStore,
              ),
              SettingsCard(
                text: "Share App",
                icon: Icon(Icons.share),
                onTap: _shareApp,
              ),

              // section 4
              SizedBox(height: AppSizes.vLarge),
              SettingsCard(
                text: "Reset Password",
                icon: Icon(Icons.lock_reset_outlined),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.forgotPassword),
              ),
              SettingsCard(
                text: "Log out",
                icon: Icon(Icons.logout),
                onTap: () async {
                  final bool confirm = await ConfirmDialog.show(
                    context,
                    content: "You will be logged out of your account.",
                    confirmColor: AppColors.error,
                    cancelColor: AppColors.primary,
                    confirmText: "Logout",
                  );
                  if (confirm) {
                    ref.read(authProvider.notifier).signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    }
                  }
                },
                color: AppColors.error,
              ),
              SettingsCard(
                text: "Delete Account",
                icon: Icon(Icons.delete_forever_outlined),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.deleteAccount),
                color: AppColors.error,
              ),

              SizedBox(height: AppSizes.vLarge),
              // version
              Text(
                "Version 2.3.0",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: AppSizes.vLarge),
            ],
          ),
        ),
      ),
    );
  }
}
