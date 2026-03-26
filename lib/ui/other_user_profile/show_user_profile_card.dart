import 'package:air_query/core/widgets/stat_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_sizes.dart';
import 'notifier/other_user_profile_notifier.dart';

void showUserProfileCard(BuildContext context, String uid) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Padding(
        padding: const .all(AppSizes.medium),
        child: Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(otherUserProfileProvider(uid));

            return state.when(
              // loading state
              loading: () => const SizedBox(
                height: AppSizes.heroIcon,
                width: AppSizes.heroIcon,
                child: Center(child: CircularProgressIndicator()),
              ),
              // error state
              error: (e, _) => SizedBox(
                height: AppSizes.heroIcon,
                child: Center(child: Text(e.toString())),
              ),
              // profile data
              data: (user) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          style: Theme.of(context).textTheme.labelLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: .zero,
                        constraints: const BoxConstraints(),
                        visualDensity: .compact,
                      ),
                    ],
                  ),

                  // campus and semester
                  _profileRow(context, label: "Campus", value: user.campus),
                  _profileRow(context, label: "Semester", value: user.semester),

                  SizedBox(height: AppSizes.vLarge),

                  // stats
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: StatBox(
                            label: "Lifetime Queries",
                            value: user.queriesPosted,
                          ),
                        ),
                        const SizedBox(width: AppSizes.medium),
                        Expanded(
                          child: StatBox(
                            label: "Lifetime Responses",
                            value: user.responsesPosted,
                          ),
                        ),
                        const SizedBox(width: AppSizes.medium),
                        Expanded(
                          child: StatBox(
                            label: "Queries Resolved",
                            value: user.queriesResolved,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}

Widget _profileRow(
    BuildContext context, {
      required String label,
      required String value,
    }) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSizes.minute),
    child: Row(
      children: [
        Text("$label: ", style: Theme.of(context).textTheme.titleSmall),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
