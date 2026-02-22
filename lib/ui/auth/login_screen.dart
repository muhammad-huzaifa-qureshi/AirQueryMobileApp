import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:flutter/material.dart';

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
            padding: .all(AppSizes.medium),
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
                  const SizedBox(height: AppSizes.small),
                  Text(
                    "Unofficial platform for Air University Pakistan Students' Queries!",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: .center,
                  ),
                  const SizedBox(height: AppSizes.large),

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
                    validator: (value) {
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.small),

                  // password field
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: .text,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),

                  // buttons
                  const SizedBox(height: AppSizes.large),
                  CTAButton(text: "Login", onPressed: () {}),
                  const SizedBox(height: AppSizes.small),
                  CTAButton(
                    text: "New? Make a free account!",
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                    isPrimary: false,
                  ),

                  const SizedBox(height: AppSizes.medium),
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
