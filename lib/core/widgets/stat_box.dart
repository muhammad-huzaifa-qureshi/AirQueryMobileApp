import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';

class StatBox extends StatelessWidget {
  final String label;
  final int value;

  const StatBox({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.medium),
      decoration: BoxDecoration(
        color: AppColors.blackish,
        borderRadius: BorderRadius.circular(AppSizes.medium),
        border: Border.all(color: AppColors.greyish),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.vSmall),
          Text(
            label,
            textAlign: .center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.greyish),
          ),
        ],
      ),
    );
  }
}
