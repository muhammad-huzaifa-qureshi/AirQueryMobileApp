import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register"),),
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
                    "Create Your Account",
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: .center,
                  ),
                  const SizedBox(height: AppSizes.small),
                  Text(
                    "Your data is stored in Cloud securely. Passwords are encrypted!",
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
                      hintText: "Min. 8 characters",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),

                  // buttons
                  const SizedBox(height: AppSizes.large),
                  CTAButton(text: "Register", onPressed: () {}),
                  const SizedBox(height: AppSizes.small),
                  CTAButton(
                    text: "Already have an account? Login",
                    onPressed: () {},
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
