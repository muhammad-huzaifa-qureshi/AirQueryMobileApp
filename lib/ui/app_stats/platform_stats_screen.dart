import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/widgets/stat_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'notifier/platform_stats_notifier.dart';

class PlatformStatsScreen extends ConsumerWidget {
  const PlatformStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(platformStatsProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Platform Stats")),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(platformStatsProvider);

            // Loading
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error
            if (state.stats == null && state.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Failed to load stats."),
                    const SizedBox(height: AppSizes.small),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(platformStatsProvider.notifier).fetchStats(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            final stats = state.stats!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Heading
                  Text(
                    "Our Impact",
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSizes.small),

                  // Subtitle
                  Text(
                    "Here's what our community has achieved so far.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSizes.vLarge),

                  // 3 stat boxes
                  Row(
                    children: [
                      Expanded(
                        child: StatBox(
                          label: "Queries Posted",
                          value: stats.totalQueriesPosted,
                        ),
                      ),
                      const SizedBox(width: AppSizes.medium),
                      Expanded(
                        child: StatBox(
                          label: "Resolved",
                          value: stats.totalQueriesResolved,
                        ),
                      ),
                      const SizedBox(width: AppSizes.medium),
                      Expanded(
                        child: StatBox(
                          label: "Responses",
                          value: stats.totalResponses,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.medium),
                  Text(
                    "Since April, 2026",
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: .center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
