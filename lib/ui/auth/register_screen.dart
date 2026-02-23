import 'package:air_query/core/constants/app_spacings.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/utils/auth_validators.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthEmailNotVerified) {
            Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.emailVerify, (route) => false,);
          }
          if (state is AuthEmailNotVerified) {
            Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.emailVerify, (route) => false,);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: _buildForm(context),
      ),
    );
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
                  "Create Your Account",
                  style: Theme
                      .of(context)
                      .textTheme
                      .displayLarge,
                  textAlign: .center,
                ),
                const SizedBox(height: AppSpacings.small),
                Text(
                  "Your data is stored in Cloud securely. Passwords are encrypted!",
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,
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
                    suffixText: "@students.au.edu.pk",
                  ),
                  validator: AuthValidators.validateAuId,
                ),
                const SizedBox(height: AppSpacings.small),

                // password field
                TextFormField(
                  controller: _passwordController,
                  keyboardType: .text,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    hintText: "Min. 8 characters",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: AuthValidators.validatePassword,
                ),

                // buttons
                const SizedBox(height: AppSpacings.large),
                BlocSelector<AuthBloc, AuthState, bool>(
                  selector: (state) => state is AuthLoading,
                  builder: (context, isLoading) {
                    return CTAButton(
                      text: isLoading ? "wait..." : "Register",
                      onPressed: isLoading
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            RegisterRequested(
                              "${_idController.text.trim()}@students.au.edu.pk",
                              _passwordController.text.trim(),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacings.small),
                CTAButton(
                  text: "Already have an account? Login",
                  onPressed: () => Navigator.pop(context),
                  isPrimary: false,
                ),

                const SizedBox(height: AppSpacings.medium),
                Text(
                  "Developed by an Airian, for the Airians 💌",
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,
                  textAlign: .center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
