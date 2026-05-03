import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/utils/format_time.dart';
import 'package:air_query/core/widgets/confirm_dialog.dart';
import 'package:air_query/ui/other_user_profile/show_user_profile_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/query_model.dart';
import '../constants/app_icons.dart';
import '../theme/query_colors.dart';

enum _QueryAction { delete, resolve, report }

class QueryCard extends StatelessWidget {
  final QueryModel query;
  final bool isOwnQuery;
  final int colorIndex;

  final VoidCallback? onDelete;
  final VoidCallback? onResolve;
  final VoidCallback? onReport;

  const QueryCard({
    super.key,
    required this.query,
    required this.isOwnQuery,
    required this.colorIndex,
    this.onDelete,
    this.onResolve,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final queryColor =
        QueryColors.strokes[colorIndex % QueryColors.strokes.length];

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.responses,
        arguments: query.id,
      ),
      child: Container(
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
                  child: GestureDetector(
                    onTap: isOwnQuery
                        ? () => Navigator.pushNamed(context, AppRoutes.profile)
                        : () => showUserProfileCard(context, query.postedByUid),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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

                        // premium icon
                        if (query.postedByIsPremium) ...[
                          const SizedBox(width: AppSizes.vSmall),
                          Tooltip(
                            triggerMode: .tap,
                            message: "Premium User",
                            child: Icon(
                              AppIcons.premium,
                              size: AppSizes.mediumIcon,
                              color: queryColor,
                            ),
                          ),
                        ],

                        // insider icon
                        if (query.postedByIsInsider) ...[
                          const SizedBox(width: AppSizes.vSmall),
                          Tooltip(
                            triggerMode: .tap,
                            message: "Insider",
                            child: Icon(
                              AppIcons.insider,
                              size: AppSizes.mediumIcon,
                              color: AppColors.whitish,
                            ),
                          ),
                        ],
                      ],
                    ),
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

            if (query.isResolved) ...[
              const SizedBox(height: AppSizes.vSmall),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: queryColor,
                    size: AppSizes.smallIcon,
                  ),
                  const SizedBox(width: AppSizes.vSmall),
                  Text(
                    "Resolved",
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: queryColor),
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppSizes.small),

            // Description
            Linkify(
              text: query.description,
              style: Theme.of(context).textTheme.bodyMedium,
              linkStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: queryColor),
              onOpen: (link) async {
                final uri = Uri.parse(link.url);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),

            if (query.imagePath != null) ...[
              const SizedBox(height: AppSizes.medium),
              _QueryImage(imagePath: query.imagePath!),
            ],

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
                if (isOwnQuery) ...[
                  const Spacer(),
                  _buildMenu(context),
                ] else ...[
                  const Spacer(),
                  _buildGuestMenu(context),
                ],
              ],
            ),
          ],
        ),
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
                "It will be tagged as \"resolved\" and deleted after ${BusinessConstants.resolvedQueryTTLDays} days.",
            cancelColor: AppColors.primary,
            confirmColor: AppColors.error,
          );
          if (confirmed) onResolve?.call();
        }
      },
      itemBuilder: (_) => [
        if (query.isResolved)
          PopupMenuItem(
            enabled: false,
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: AppSizes.mediumIcon,
                ),
                SizedBox(width: AppSizes.vSmall),
                Text("Resolved", style: TextStyle(color: AppColors.primary)),
              ],
            ),
          )
        else
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

  Widget _buildGuestMenu(BuildContext context) {
    return PopupMenuButton<_QueryAction>(
      color: AppColors.blackish,
      icon: Icon(Icons.more_horiz, color: AppColors.whitish),
      tooltip: "Menu",
      onSelected: (action) async {
        if (action == _QueryAction.report) {
          final confirmed = await ConfirmDialog.show(
            context,
            content: 'Report this query as inappropriate or spam?',
            cancelColor: AppColors.primary,
            confirmColor: AppColors.error,
          );
          if (confirmed) onReport?.call();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _QueryAction.report,
          child: Row(
            children: [
              Icon(
                Icons.flag_outlined,
                color: AppColors.error,
                size: AppSizes.mediumIcon,
              ),
              SizedBox(width: AppSizes.vSmall),
              Text("Report", style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }
}

class _QueryImage extends StatefulWidget {
  final String imagePath;

  const _QueryImage({required this.imagePath});

  @override
  State<_QueryImage> createState() => _QueryImageState();
}

class _QueryImageState extends State<_QueryImage> {
  String? _url;
  bool _error = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    try {
      final url = await FirebaseStorage.instance
          .ref(widget.imagePath)
          .getDownloadURL();
      if (mounted) {
        setState(() {
          _url = url;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) return const SizedBox.shrink();

    if (_loading) {
      return const SizedBox(
        height: AppSizes.heroIcon,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: AppSizes.minute),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.medium),
      child: CachedNetworkImage(
        imageUrl: _url!,
        width: .infinity,
        fit: .cover,
        // while image bytes load
        placeholder: (_, _) => const SizedBox(
          height: AppSizes.heroIcon,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: AppSizes.minute),
          ),
        ),
        // if image URL is valid but bytes fail
        errorWidget: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
