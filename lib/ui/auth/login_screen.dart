import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/core/constants/app_spacings.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/utils/auth_validators.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/auth/notifier/auth_notifier.dart';
import 'package:air_query/ui/auth/notifier/auth_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  @override
  void dispose() {
    _idController.dispose();
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
        if (next.value == AuthStatus.authenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
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

    return Scaffold(body: _buildForm(context));
  }

  Widget _buildForm(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: .all(AppSpacings.medium),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .stretch,
              children: [
                // header
                Text(
                  "Welcome to Air Query",
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: .center,
                ),
                const SizedBox(height: AppSpacings.small),
                Text(
                  "Unofficial platform for Air University Pakistan Students' Queries!",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: .center,
                ),
                const SizedBox(height: AppSpacings.large),

                // id field
                TextFormField(
                  controller: _idController,
                  keyboardType: .number,
                  textInputAction: .next,
                  decoration: const InputDecoration(
                    labelText: "AU Email",
                    hintText: "eg: 000000",
                    prefixIcon: Icon(Icons.email_outlined),
                    suffixText: BusinessConstants.auEmailDomain,
                  ),
                  validator: AuthValidators.validateAuId,
                ),
                const SizedBox(height: AppSpacings.small),

                // password field
                TextFormField(
                  controller: _passwordController,
                  keyboardType: .text,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.forgotPassword),
                    child: Text(
                      "Forgot password?",
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ),
                ),

                // buttons
                const SizedBox(height: AppSpacings.large),
                Consumer(
                  builder: (context, ref, _) {
                    final isLoading = ref.watch(
                      authProvider.select((value) => value.isLoading),
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CTAButton(
                          text: isLoading ? "wait..." : "Login",
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    FocusScope.of(context).unfocus();
                                    ref
                                        .read(authProvider.notifier)
                                        .login(
                                          id: _idController.text.trim(),
                                          password: _passwordController.text
                                              .trim(),
                                        );
                                  }
                                },
                        ),
                        const SizedBox(height: AppSpacings.small),
                        CTAButton(
                          text: "New? Make a free account!",
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.register),
                          isPrimary: false,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: AppSpacings.medium),
                Text(
                  "Developed by an Airian, for the Airians 💌",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
