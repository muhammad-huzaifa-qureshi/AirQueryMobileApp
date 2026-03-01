import 'dart:async';
import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/core/constants/app_spacings.dart';
import 'package:air_query/core/utils/auth_validators.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/auth/notifier/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  
  bool _resetSent = false;
  Timer? _cooldownTimer;
  int _cooldownRemaining = 0;

  @override
  void dispose() {
    _idController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _cooldownRemaining = BusinessConstants.resendCooldownSeconds;
      _resetSent = true;
    });

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

  void _sendResetEmail() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      ref.read(authProvider.notifier).sendPasswordReset(
            "${_idController.text.trim()}${BusinessConstants.auEmailDomain}",
          );
      _startCooldown();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacings.medium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                "Reset Password",
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacings.small),
              Text(
                _resetSent
                    ? "If an account exists, a reset link has been sent to your email. Please check your spam folder too."
                    : "Enter your AU student ID to receive a password reset link.",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacings.large),

              // Form
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: "AU Email",
                    hintText: "eg: 000000",
                    prefixIcon: Icon(Icons.email_outlined),
                    suffixText: BusinessConstants.auEmailDomain,
                  ),
                  validator: AuthValidators.validateAuId,
                ),
              ),

              // Buttons
              const SizedBox(height: AppSpacings.large),
              Consumer(
                builder: (context, ref, _) {
                  final isLoading = ref.watch(
                    authProvider.select((value) => value.isLoading),
                  );
                  return CTAButton(
                    text: isLoading
                        ? "Sending..."
                        : _cooldownRemaining > 0
                            ? "Resend in ${_cooldownRemaining}s"
                            : _resetSent
                                ? "Resend Link"
                                : "Send Reset Link",
                    onPressed: (isLoading || _cooldownRemaining > 0)
                        ? null
                        : _sendResetEmail,
                  );
                },
              ),
              const SizedBox(height: AppSpacings.small),
              CTAButton(
                text: "Back to Login",
                onPressed: () => Navigator.pop(context),
                isPrimary: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
