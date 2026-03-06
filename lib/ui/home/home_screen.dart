import 'package:air_query/core/constants/app_spacings.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/ui/home/notifier/home_notifier.dart';
import 'package:air_query/ui/home/widgets/query_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
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
            onPressed: () => Navigator.pushNamed(context, AppRoutes.about),
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
        if (state.queries.isEmpty) {
          return const Center(
            child: Text("No queries yet. Be the first to post!"),
          );
        }

        // Empty + error state
        if (state.queries.isEmpty && state.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Failed to load queries."),
                const SizedBox(height: AppSpacings.small),
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
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            // to enable pull to refresh all time
            padding: const .all(AppSpacings.medium),
            itemCount: state.queries.length + (state.isLoadingMore ? 1 : 0) + 1,
            // +1 for hint text added
            itemBuilder: (context, index) {
              // hint text
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacings.small),
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
                  padding: .symmetric(vertical: AppSpacings.medium),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return QueryCard(query: state.queries[index - 1]);
            },
          ),
        );
      },
    );
  }
}
