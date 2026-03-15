import 'dart:math';

import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/widgets/confirm_dialog.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/auth/notifier/auth_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  late final int n1, n2, product;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final random = Random();
    n1 = random.nextInt(10) + 1; // 1 to 10
    n2 = random.nextInt(10) + 1;
    product = n1 * n2;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDelete() async {
    final answer = int.tryParse(_controller.text);
    if (answer != product) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Incorrect answer")));
      return;
    }

    if (!context.mounted) return;
    final confirm = await ConfirmDialog.show(
      context,
      content: "This action is irreversible!",
      confirmText: "Delete",
      confirmColor: AppColors.error,
    );
    if (confirm) {
      await ref.read(authProvider.notifier).deleteAccount();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Account Deleted Successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(title: Text("Delete My Account")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: .all(AppSizes.medium),
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              // emoji
              Text(
                "😔",
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: .center,
              ),
              // texts
              const SizedBox(height: AppSizes.medium),
              Text(
                "We're sorry to see you go.",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: .center,
              ),
              const SizedBox(height: AppSizes.small),
              Text(
                "Deleting your account will permanently remove all your data. This action cannot be undone.",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.vLarge),
              Text(
                "Solve this to confirm deletion: $n1 x $n2 = ?",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: AppSizes.small),
              // text field
              TextField(
                keyboardType: .number,
                controller: _controller,
                textInputAction: .done,
                decoration: InputDecoration(
                  labelText: "Product",
                  prefixIcon: Icon(Icons.help_outline),
                ),
              ),
              SizedBox(height: AppSizes.large),
              // CTA
              Consumer(
                builder: (BuildContext context, WidgetRef ref, _) {
                  final isLoading = ref.watch(
                    authProvider.select((s) => s.isLoading),
                  );
                  return CTAButton(
                    text: "Delete Permanently",
                    isDanger: true,
                    onPressed: _onDelete,
                    isLoading: isLoading,
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
