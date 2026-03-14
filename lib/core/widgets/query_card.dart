import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/utils/format_time.dart';
import 'package:air_query/core/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import '../theme/query_colors.dart';
import '../../models/query_model.dart';

enum _QueryAction { delete, resolve }

class QueryCard extends StatelessWidget {
  final QueryModel query;
  final bool isOwnQuery;
  final int colorIndex;

  final VoidCallback? onDelete;
  final VoidCallback? onResolve;

  const QueryCard({
    super.key,
    required this.query,
    required this.isOwnQuery,
    required this.colorIndex,
    this.onDelete,
    this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final queryColor =
        QueryColors.strokes[colorIndex % QueryColors.strokes.length];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.small),
      padding: const EdgeInsets.all(AppSizes.medium),

      decoration: BoxDecoration(
        color: AppColors.blackish,
        borderRadius: BorderRadius.circular(AppSizes.medium),
        boxShadow: [
          BoxShadow(
            color: queryColor,
            blurRadius: 1,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author and time row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  isOwnQuery
                      ? "${query.postedByName} (Me)"
                      : query.postedByName,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: queryColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                formatTime(query.postedAt),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: queryColor),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.vSmall),
          // campus
          Text(
            "For ${query.campus == "All" ? "All Campuses" : query.campus}",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: queryColor),
          ),

          const SizedBox(height: AppSizes.medium),

          // Description
          Text(
            query.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: AppSizes.medium),

          // Bottom row
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '${query.responseCount}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(width: AppSizes.minute),
              IconButton(
                color: AppColors.whitish,
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.responses,
                  arguments: query.id,
                ),
                icon: const Icon(Icons.comment),
                tooltip: "Responses",
              ),
              if (isOwnQuery) ...[const Spacer(), _buildMenu(context)],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<_QueryAction>(
      color: AppColors.blackish,
      icon: Icon(Icons.more_horiz, color: AppColors.whitish),
      tooltip: "Menu",
      onSelected: (action) async {
        if (action == _QueryAction.delete) {
          final confirmed = await ConfirmDialog.show(
            context,
            content: 'This query will be permanently deleted.',
            cancelColor: AppColors.primary,
            confirmColor: AppColors.error,
          );
          if (confirmed) onDelete?.call();
        } else if (action == _QueryAction.resolve) {
          final confirmed = await ConfirmDialog.show(
            context,
            content:
                "Mark this query as resolved? Once resolved, it will no longer appear in your profile.",
            cancelColor: AppColors.primary,
            confirmColor: AppColors.error,
          );
          if (confirmed) onResolve?.call();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _QueryAction.resolve,
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: AppSizes.mediumIcon),
              SizedBox(width: AppSizes.vSmall),
              Text("Mark as Resolved"),
            ],
          ),
        ),
        PopupMenuItem(
          value: _QueryAction.delete,
          child: Row(
            children: [
              Icon(
                Icons.delete_forever_outlined,
                color: AppColors.error,
                size: AppSizes.mediumIcon,
              ),
              SizedBox(width: AppSizes.vSmall),
              Text("Delete", style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }
}
