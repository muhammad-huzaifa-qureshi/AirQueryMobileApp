import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/core/constants/app_spacings.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/utils/auth_validators.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/auth/notifier/auth_notifier.dart';
import 'package:air_query/ui/auth/notifier/auth_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
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
      }
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacings.medium),
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
                const SizedBox(height: AppSpacings.small),
                Text(
                  "Your data is stored in Cloud securely. Passwords are encrypted!",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacings.large),

                // id field
                TextFormField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
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
                          text: isLoading ? "wait..." : "Register",
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    FocusScope.of(context).unfocus();
                                    ref
                                        .read(authProvider.notifier)
                                        .register(
                                          id: _idController.text.trim(),
                                          password: _passwordController.text
                                              .trim(),
                                        );
                                  }
                                },
                        ),
                        const SizedBox(height: AppSpacings.small),
                        CTAButton(
                          text: "Already have an account? Login",
                          onPressed: () => Navigator.pop(context),
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
