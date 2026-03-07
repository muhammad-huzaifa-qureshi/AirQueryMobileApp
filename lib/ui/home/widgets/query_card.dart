import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/utils/format_time.dart';
import 'package:flutter/material.dart';

import '../../../models/query_model.dart';

class QueryCard extends StatelessWidget {
  final QueryModel query;
  final bool isOwnQuery;

  const QueryCard({super.key, required this.query, required this.isOwnQuery});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.small),
      padding: const EdgeInsets.all(AppSizes.medium),

      decoration: BoxDecoration(
        color: AppColors.blackish,
        borderRadius: BorderRadius.circular(AppSizes.medium),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary,
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
              Text(
                query.postedByName,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                formatTime(query.postedAt),
                style: Theme.of(context).textTheme.labelSmall,
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
                style: Theme.of(
                  context,
                ).textTheme.labelMedium,
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
                IconButton(
                  color: AppColors.error,
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline),
                  tooltip: "Delete",
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
