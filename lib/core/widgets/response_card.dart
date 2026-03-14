import 'package:flutter/material.dart';

import '../../models/response_model.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';
import '../utils/format_time.dart';
import 'confirm_dialog.dart';

class ResponseCard extends StatelessWidget {
  final ResponseModel response;
  final bool isOwn;
  final VoidCallback? onDelete;

  const ResponseCard({
    super.key,
    required this.response,
    required this.isOwn,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const .only(bottom: AppSizes.small),
      padding: const .all(AppSizes.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  isOwn
                      ? "${response.postedByName} (Me)"
                      : response.postedByName,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatTime(response.postedAt),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  if (isOwn) ...[
                    const SizedBox(width: AppSizes.small),
                    GestureDetector(
                      onTap: () async {
                        final confirmed = await ConfirmDialog.show(
                          context,
                          content: "This response will be permanently deleted.",
                          cancelColor: AppColors.primary,
                          confirmColor: AppColors.error,
                        );
                        if (confirmed) onDelete?.call();
                      },
                      child: Icon(
                        Icons.delete_outline,
                        size: AppSizes.mediumIcon,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.vSmall),
          Text(
            response.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
