import 'package:air_query/core/constants/app_sizes.dart';
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
                  Text(
                    "Welcome to Air Query",
                    style: Theme.of(context).textTheme.displaySmall,
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
                      hintText: "Minimum 8 characters",
                    ),
                    validator: (value) {
                      return null;
                    },
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
