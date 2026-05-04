import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/widgets/query_card.dart';
import 'package:air_query/ui/home/notifier/home_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  // get the controller from MAIN,
  // for supporting the feature:
  // on "Bottom NavBar Home click -> scrolls to top"
  final ScrollController scrollController;

  const HomeScreen({super.key, required this.scrollController});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final String? _currentUId;

  @override
  void initState() {
    super.initState();
    // for detecting if its own query
    _currentUId = ref.read(homeProvider.notifier).currentUserID;
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final pos = widget.scrollController.position;
    final state = ref.read(homeProvider);

    if (!state.isLoadingMore && pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(homeProvider.notifier).fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Snackbar
    ref.listen(homeProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Air Query"),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.badges),
            icon: Icon(Icons.workspace_premium, color: AppColors.golden,),
            tooltip: "Badges Info",
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.postQuery),
        tooltip: "Post a Query",
        child: const Icon(Icons.add),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(homeProvider);

        // Initial loading
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // no queries
        if (state.queries.isEmpty && state.error == null) {
          return Center(
            child: Column(
              mainAxisSize: .min,
              children: [
                const Text("No queries yet. Be the first to post!"),
                const SizedBox(height: AppSizes.small),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(homeProvider.notifier).fetchInitial(),
                  child: const Text("Refresh"),
                ),
              ],
            ),
          );
        }

        // Empty + error state
        if (state.queries.isEmpty && state.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Failed to load queries."),
                const SizedBox(height: AppSizes.small),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(homeProvider.notifier).fetchInitial(),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        // Feed
        return RefreshIndicator(
          onRefresh: () => ref.read(homeProvider.notifier).refresh(),
          child: ListView.builder(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(), // to enable pull to refresh all time
            padding: const EdgeInsets.fromLTRB(
              AppSizes.medium,
              AppSizes.medium,
              AppSizes.medium,
              AppSizes.fabBottomPadding, // space for FAB
            ),
            itemCount: state.queries.length + (state.isLoadingMore ? 1 : 0) + 1,
            // +1 for hint text added
            itemBuilder: (context, index) {
              // hint text
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.small),
                  child: Center(
                    child: Text(
                      "Pull down to refresh feed!",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              }
              // Bottom loader
              if (index == state.queries.length + 1) {
                return const Padding(
                  padding: .symmetric(vertical: AppSizes.medium),
                  child: Center(
                    child: SizedBox(
                      width: AppSizes.medium,
                      height: AppSizes.medium,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              final query = state.queries[index - 1];

              return QueryCard(
                isOwnQuery: query.postedByUid == _currentUId,
                query: query,
                colorIndex: index - 1,
                onDelete: query.postedByUid == _currentUId
                    ? () =>
                          ref.read(homeProvider.notifier).deleteQuery(query.id)
                    : null,
                onResolve: query.postedByUid == _currentUId
                    ? () =>
                          ref.read(homeProvider.notifier).resolveQuery(query.id)
                    : null,
                onReport: query.postedByUid != _currentUId
                    ? () => ref.read(homeProvider.notifier).reportQuery(query)
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}
