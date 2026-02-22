import 'package:air_query/core/constants/app_spacings.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/utils/auth_validators.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/auth/bloc/auth_bloc.dart';
import 'package:air_query/ui/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                      suffixText: "@students.au.edu.pk",
                    ),
                    validator: AuthValidators.validateAuId,
                  ),
                  const SizedBox(height: AppSpacings.small),

                  // password field
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: .text,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: AuthValidators.validatePassword,
                  ),

                  // buttons
                  const SizedBox(height: AppSpacings.large),
                  CTAButton(
                    text: "Login",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                          LoginRequested(
                            "${_idController.text.trim()}@students.au.edu.pk",
                            _passwordController.text.trim(),
                          ),
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

                  const SizedBox(height: AppSpacings.medium),
                  Text(
                    "Developed by an Airian, for the Airians 💌",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: .center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
