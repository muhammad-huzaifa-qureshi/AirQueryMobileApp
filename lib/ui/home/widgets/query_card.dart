import 'package:air_query/core/constants/app_spacings.dart';
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
      margin: const EdgeInsets.symmetric(vertical: AppSpacings.small),
      padding: const EdgeInsets.all(AppSpacings.medium),

      decoration: BoxDecoration(
        color: AppColors.blackish,
        borderRadius: BorderRadius.circular(AppSpacings.medium),
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

          const SizedBox(height: AppSpacings.small),

          // Description
          Text(
            query.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: AppSpacings.medium),

          // Response count + comments button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${query.responseCount}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.whitish),
              ),
              const SizedBox(width: AppSpacings.vSmall),
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
