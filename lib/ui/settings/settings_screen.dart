import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/widgets/confirm_dialog.dart';
import 'package:air_query/ui/auth/notifier/auth_notifier.dart';
import 'package:air_query/ui/settings/widgets/settings_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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
            ],
          ),
        ),
      ),
    );
  }
}
