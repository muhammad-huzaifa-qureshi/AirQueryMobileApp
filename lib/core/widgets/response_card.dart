import 'package:air_query/ui/other_user_profile/show_user_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/response_model.dart';
import '../../ui/responses/notifier/reply_notifier.dart';
import '../constants/app_sizes.dart';
import '../constants/business_constants.dart';
import '../routing/app_routes.dart';
import '../theme/app_colors.dart';
import '../utils/format_time.dart';
import 'confirm_dialog.dart';

class ResponseCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const .only(bottom: AppSizes.medium),
      padding: const .all(AppSizes.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: isOwn
                      ? () => Navigator.pushNamed(context, AppRoutes.profile)
                      : () =>
                            showUserProfileCard(context, response.postedByUid),
                  child: Row(
                    children: [
                      Text(
                        isOwn
                            ? "${response.postedByName} (Me)"
                            : response.postedByName,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.primary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (response.postedByUid == BusinessConstants.devUid) ...[
                        const SizedBox(width: AppSizes.vSmall),
                        Icon(
                          Icons.verified,
                          size: AppSizes.smallIcon,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
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

          // Show mention badge if someone is mentioned
          if (response.hasMention) ...[
            Container(
              margin: const .only(bottom: AppSizes.vSmall),
              padding: const .symmetric(vertical: AppSizes.vSmall),
              decoration: BoxDecoration(color: AppColors.blackish),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.reply_rounded,
                    size: AppSizes.smallIcon,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSizes.vSmall),
                  Flexible(
                    child: GestureDetector(
                      onTap: response.mentionedUid != null
                          ? () => showUserProfileCard(
                              context,
                              response.mentionedUid!,
                            )
                          : null,
                      child: Text(
                        "Replying to @${response.mentionedName}",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                        overflow: .ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          Linkify(
            text: response.description,
            style: Theme.of(context).textTheme.bodyLarge,
            linkStyle: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.primary),
            onOpen: (link) async {
              final uri = Uri.parse(link.url);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),

          if (!isOwn) ...[
            SizedBox(height: AppSizes.small),
            Align(
              alignment: .centerLeft,
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(replyStateProvider.notifier)
                      .setReply(response.postedByUid, response.postedByName);
                },
                child: Text(
                  "Reply",
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
