import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CTAButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final bool isDanger;
  final bool isDisabled;
  final bool isPremium;

  const CTAButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.isDanger = false,
    this.isDisabled = false,
    this.isPremium = false,
  });

  bool get _isInactive => isDisabled || isLoading || onPressed == null;

  Color _getBg() {
    if (_isInactive) return AppColors.greyish;
    if (!isPrimary) return Colors.transparent;
    if (isDanger) return AppColors.error;
    return isPremium ? AppColors.golden : AppColors.primary;
  }

  Color _getFg() {
    if (_isInactive) return AppColors.whitish;
    if (isPrimary) {
      if (isDanger) return AppColors.whitish;
      return AppColors.blackish;
    }
    if (isDanger) return AppColors.error;
    return isPremium ? AppColors.golden : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _getBg();
    final Color fgColor = _getFg();

    return TextButton(
      onPressed: _isInactive ? null : onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,

        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: (isPrimary || _isInactive)
              ? BorderSide.none
              : BorderSide(color: fgColor, width: 1),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: fgColor),
            )
          : Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: fgColor),
            ),
    );
  }
}
