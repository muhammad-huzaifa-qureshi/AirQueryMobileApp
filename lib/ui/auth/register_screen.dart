import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/utils/auth_validators.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/auth/notifier/auth_notifier.dart';
import 'package:air_query/ui/auth/notifier/auth_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_external_launchers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (prev, next) {
      if (next is AsyncData<AuthStatus>) {
        if (next.value == AuthStatus.emailNotVerified) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.emailVerify,
            (route) => false,
          );
        }
      }
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
        actions: [
          IconButton(
            onPressed: AppExternalLaunchers.launchAuthorEmail,
            icon: Icon(Icons.headphones),
            tooltip: "Email Support",
          ),
        ],
      ),
      body: _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.medium),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // header
                Text(
                  "Create Your Account",
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.small),
                Text(
                  "Your information is protected: cloud-secured data, private email, and encrypted passwords.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.medium),

                // use AU email
                Text(
                  "Use AU email to get Insider badge!",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                  textAlign: .center,
                ),
                const SizedBox(height: AppSizes.large),

                // id field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: AuthValidators.validateEmail,
                ),
                const SizedBox(height: AppSizes.small),

                // password field
                TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Min. 8 characters",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: AuthValidators.validatePassword,
                ),

                // buttons
                const SizedBox(height: AppSizes.large),
                Consumer(
                  builder: (context, ref, _) {
                    final isLoading = ref.watch(
                      authProvider.select((value) => value.isLoading),
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CTAButton(
                          text: isLoading ? "wait..." : "Register",
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    FocusScope.of(context).unfocus();
                                    ref
                                        .read(authProvider.notifier)
                                        .register(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text
                                              .trim(),
                                        );
                                  }
                                },
                        ),
                        const SizedBox(height: AppSizes.small),
                        CTAButton(
                          text: "Already have an account? Login",
                          onPressed: () => Navigator.pop(context),
                          isPrimary: false,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: AppSizes.medium),
                Text(
                  "Developed by an Airian, for the Airians 💌",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.medium),
                GestureDetector(
                  onTap: _launchPrivacyPolicy,
                  child: Text(
                    "Privacy Policy",
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    final uri = Uri.parse(BusinessConstants.privacyPolicy);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
