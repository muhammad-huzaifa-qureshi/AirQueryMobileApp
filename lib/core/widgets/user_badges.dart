import 'package:air_query/core/constants/app_icons.dart';
import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class UserBadges extends StatelessWidget {
  final bool isInsider;
  final bool isPremium;

  const UserBadges({
    super.key,
    required this.isInsider,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    if (!isInsider && !isPremium) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isPremium)
          _Badge(
            icon: AppIcons.premium,
            label: 'Premium',
            color: AppColors.primary,
          ),
        if (isPremium) const SizedBox(width: AppSizes.small),
        if (isInsider) ...[
          _Badge(
            icon: AppIcons.insider,
            label: 'Insider',
            color: AppColors.whitish,
          ),
        ],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.medium,
        vertical: AppSizes.vSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.blackish,
        borderRadius: BorderRadius.circular(AppSizes.vLarge),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.smallIcon, color: color),
          const SizedBox(width: AppSizes.vSmall),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
