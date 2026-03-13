import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final Color? cancelColor;

  const ConfirmDialog({
    super.key,
    this.title = "Are you sure?",
    required this.content,
    this.confirmText = "Confirm",
    this.cancelText = "Cancel",
    this.confirmColor,
    this.cancelColor,
  });

  static Future<bool> show(
    BuildContext context, {
    required String content,
    String title = "Are you sure?",
    String confirmText = "Confirm",
    String cancelText = "Cancel",
    Color? confirmColor,
    Color? cancelColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText, style: TextStyle(color: cancelColor)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText, style: TextStyle(color: confirmColor)),
        ),
      ],
    );
  }
}
