import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/utils/format_time.dart';
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

          const SizedBox(height: AppSizes.small),

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
                onPressed: () {},
                icon: const Icon(Icons.comment),
                tooltip: "Responses",
              ),
              if (isOwnQuery) ...[
                const Spacer(),
                PopupMenuButton<_QueryAction>(
                  color: AppColors.blackish,
                  icon: Icon(Icons.more_horiz, color: AppColors.whitish),
                  tooltip: "Menu",
                  onSelected: (action) async {
                    if (action == _QueryAction.delete) {
                      final confirmed = await _confirm(
                        context,
                        "This query will be permanently deleted.",
                      );
                      if (confirmed) onDelete?.call();
                    } else if (action == _QueryAction.resolve) {
                      final confirmed = await _confirm(
                        context,
                        "Mark this query as resolved?",
                      );
                      if (confirmed) onResolve?.call();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _QueryAction.resolve,
                      child: Text(
                        "Mark as Resolved",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                    PopupMenuItem(
                      value: _QueryAction.delete,
                      child: Text(
                        "Delete",
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _confirm(BuildContext context, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Are you sure?"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "Confirm",
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
