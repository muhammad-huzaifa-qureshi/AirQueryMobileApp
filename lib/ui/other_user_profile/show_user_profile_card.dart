import 'package:air_query/core/widgets/stat_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/user_badges.dart';
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

                  // Insider / Premium badges
                  if (user.isInsider || user.isPremium) ...[
                    const SizedBox(height: AppSizes.vSmall),
                    UserBadges(
                      isInsider: user.isInsider,
                      isPremium: user.isPremium,
                    ),
                  ],

                  // role and about
                  SizedBox(height: AppSizes.medium,),
                  _profileRow(context, label: "Role", value: user.role),
                  if (user.about != null && user.about!.isNotEmpty)
                    _profileRow(context, label: "About", value: user.about!),

                  SizedBox(height: AppSizes.large),

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ", style: Theme.of(context).textTheme.titleSmall),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            softWrap: true,
            maxLines: null,
          ),
        ),
      ],
    ),
  );
}
