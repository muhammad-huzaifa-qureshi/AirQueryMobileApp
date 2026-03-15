import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final String text;
  final Icon icon;
  final VoidCallback onTap;
  final Color? color;

  const SettingsCard({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: .only(bottom: AppSizes.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.medium),
        onTap: onTap,
        child: Padding(
          padding: const .all(AppSizes.medium),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(text, style: TextStyle(color: color ?? AppColors.whitish)),
              Icon(icon.icon, color: color ?? AppColors.whitish,),
            ],
          ),
        ),
      ),
    );
  }
}
