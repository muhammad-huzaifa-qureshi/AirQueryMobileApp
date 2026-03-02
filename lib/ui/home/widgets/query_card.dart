import 'package:air_query/core/constants/app_spacings.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/utils/format_time.dart';
import 'package:flutter/material.dart';

class QueryCard extends StatelessWidget {
  final String author;
  final String query;
  final DateTime timePosted;

  const QueryCard({
    super.key,
    required this.author,
    required this.query,
    required this.timePosted,
  });

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
            offset: Offset(1, 2),
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
              Text(author, style: Theme.of(context).textTheme.labelLarge),
              Text(
                formatTime(timePosted),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),

          const SizedBox(height: AppSpacings.small),

          // Query text
          Text(query, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
