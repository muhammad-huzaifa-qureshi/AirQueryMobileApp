import 'dart:async';
import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/auth/notifier/auth_notifier.dart';
import 'package:air_query/ui/auth/notifier/auth_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _cooldownTimer;
  int _cooldownRemaining = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldownRemaining = BusinessConstants.resendCooldownSeconds);

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(
        const Duration(seconds: BusinessConstants.timerTickSeconds), (timer) {
      if (_cooldownRemaining > 0) {
        setState(() => _cooldownRemaining-=2);
      } else {
        timer.cancel();
      }
    });
  }

  void _resendEmail() {
    ref.read(authProvider.notifier).resendVerificationEmail();
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (prev, next) {
      if (next is AsyncData<AuthStatus> &&
          next.value == AuthStatus.authenticated) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.medium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Icon(
                Icons.mark_email_unread_outlined,
                size: AppSizes.heroIcon,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSizes.large),
              Text(
                "Verify Your Email",
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.small),
              Text(
                "A verification link has been sent to your AU email. Please click the link to verify your account.\n\nDon't forget to check your spam folder!",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.vLarge),

              // Buttons
              Consumer(
                builder: (context, ref, _) {
                  final isLoading = ref.watch(
                    authProvider.select((value) => value.isLoading),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CTAButton(
                        text: isLoading ? "Checking..." : "I've Verified My Email",
                        onPressed: isLoading
                            ? null
                            : () => ref
                                .read(authProvider.notifier)
                                .checkEmailVerification(),
                      ),
                      const SizedBox(height: AppSizes.medium),
                      CTAButton(
                        text: _cooldownRemaining > 0
                            ? "Resend Link in ${_cooldownRemaining}s"
                            : "Resend Verification Email",
                        onPressed: (isLoading || _cooldownRemaining > 0)
                            ? null
                            : _resendEmail,
                        isPrimary: false,
                      ),
                      const SizedBox(height: AppSizes.small),
                      CTAButton(
                        text: "Back to Login",
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        ),
                        isPrimary: false,
                        isDanger: true,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
