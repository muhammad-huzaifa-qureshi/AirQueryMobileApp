import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/utils/format_time.dart';
import 'package:flutter/material.dart';
import '../../../models/query_model.dart';

class QueryCard extends StatelessWidget {
  final QueryModel query;

  const QueryCard({super.key, required this.query});

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

          // Response count + comments button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${query.responseCount}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.whitish),
              ),
              const SizedBox(width: AppSizes.vSmall),
              IconButton(
                color: AppColors.whitish,
                onPressed: () {},
                icon: const Icon(Icons.comment),
                tooltip: "Responses",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
