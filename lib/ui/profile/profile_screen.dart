import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/models/user_model.dart';
import 'package:air_query/ui/profile/notifier/profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/stat_box.dart';
import '../../core/widgets/user_badges.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // error snackbar
    ref.listen(profileProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(profileProvider);

            if (state.isLoading) {
              return Center(child: const CircularProgressIndicator());
            }

            // no user + error = show retry
            if (state.user == null && state.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Failed to load profile."),
                    const SizedBox(height: AppSizes.small),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(profileProvider.notifier).fetchProfile(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            if (state.user != null) {
              // profile incomplete — redirect to setup
              if (!state.user!.profileComplete) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Complete your profile to get started!"),
                      const SizedBox(height: AppSizes.medium),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.editProfile),
                        child: Text("Complete Profile"),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: ref.read(profileProvider.notifier).fetchProfile,
                child: _buildContent(context, state.user!),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pull hint
          Text(
            "Pull down to refresh profile!",
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSizes.vLarge),

          // Avatar circle
          Center(
            child: Container(
              width: AppSizes.heroIcon,
              height: AppSizes.heroIcon,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blackish,
                border: Border.all(
                  color: AppColors.primary,
                  width: AppSizes.minute,
                ),
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.medium),

          // Name
          Text(
            user.name,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),

          // Insider / Premium badges
          if (user.isInsider || user.isPremium)...[
            const SizedBox(height: AppSizes.medium),
            Center(
              child: UserBadges(
                isInsider: user.isInsider,
                isPremium: user.isPremium,
              ),
            ),
          ],

          const SizedBox(height: AppSizes.large),

          // Info card
          Container(
            padding: const EdgeInsets.all(AppSizes.medium),
            decoration: BoxDecoration(
              color: AppColors.blackish,
              borderRadius: BorderRadius.circular(AppSizes.medium),
              border: Border.all(color: AppColors.greyish),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: AppSizes.mediumIcon,
                      color: AppColors.whitish,
                    ),
                    const SizedBox(width: AppSizes.small),
                    Text(
                      "Role",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const Spacer(),
                    Text(
                      user.role,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.whitish,
                      ),
                    ),
                  ],
                ),
                const Divider(height: AppSizes.large),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: AppSizes.mediumIcon,
                      color: AppColors.whitish,
                    ),
                    const SizedBox(width: AppSizes.small),
                    Text(
                      "About",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                if(user.about!.isNotEmpty)...[
                  const SizedBox(height: AppSizes.vSmall),
                  Text(
                    user.about ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ]
              ],
            ),
          ),

          const SizedBox(height: AppSizes.large),

          // Stats row
          IntrinsicHeight(
            child: Row(
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

          // CTAs
          SizedBox(height: AppSizes.large),
          CTAButton(
            text: "My Queries",
            onPressed: () => Navigator.pushNamed(context, AppRoutes.myQueries),
          ),
          SizedBox(height: AppSizes.small),
          CTAButton(
            text: "Edit Profile",
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.editProfile),
            isPrimary: false,
          ),
        ],
      ),
    );
  }
}

