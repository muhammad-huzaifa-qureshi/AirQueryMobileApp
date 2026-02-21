import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CTAButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final bool isDanger;
  final bool isDisabled;

  const CTAButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.isDanger = false,
    this.isDisabled = false,
  });

  bool get _isInactive => isDisabled || isLoading || onPressed == null;

  Color _getBg() {
    if (_isInactive) return AppColors.greyish;
    if (!isPrimary) return Colors.transparent;
    return isDanger ? AppColors.error : AppColors.primary;
  }

  Color _getFg() {
    if (_isInactive) return AppColors.whitish;
    if (isPrimary) return isDanger ? AppColors.whitish : AppColors.blackish;
    return isDanger ? AppColors.error : AppColors.primary;
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
              : BorderSide(color: fgColor, width: 2),
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
