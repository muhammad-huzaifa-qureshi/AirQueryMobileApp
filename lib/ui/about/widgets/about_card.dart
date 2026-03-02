import 'package:air_query/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/constants/app_spacings.dart';

class AboutCard extends StatelessWidget {
  final Color backgroundColor = AppColors.blackish;
  final Color borderColor;
  final double radius = AppSpacings.medium;
  final Widget child;

  AboutCard({super.key, required this.child, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacings.medium),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: .all(color: borderColor),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
