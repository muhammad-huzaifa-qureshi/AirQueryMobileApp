import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/widgets/query_card.dart';
import 'package:air_query/ui/my_queries/notifier/my_queries_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/app_routes.dart';

class MyQueriesScreen extends ConsumerStatefulWidget {
  const MyQueriesScreen({super.key});

  @override
  ConsumerState<MyQueriesScreen> createState() => _MyQueriesScreenState();
}

class _MyQueriesScreenState extends ConsumerState<MyQueriesScreen> {
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
      ref.read(myQueriesProvider.notifier).fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(myQueriesProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("My Queries")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.postQuery),
        tooltip: "Post a new Query",
        child: const Icon(Icons.add),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(myQueriesProvider);

        // Initial loading
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // No queries
        if (state.queries.isEmpty && state.error == null) {
          return const Center(
            child: Text("You haven't posted any queries yet."),
          );
        }

        // Empty + error
        if (state.queries.isEmpty && state.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Failed to load queries."),
                const SizedBox(height: AppSizes.small),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(myQueriesProvider.notifier).fetchInitial(),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        // Feed
        return RefreshIndicator(
          onRefresh: () => ref.read(myQueriesProvider.notifier).refresh(),
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.medium),
            itemCount: state.queries.length + (state.isLoadingMore ? 1 : 0) + 1,
            itemBuilder: (context, index) {
              // Hint text
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.small),
                  child: Center(
                    child: Text(
                      "Pull down to refresh!",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              }

              // Bottom loader
              if (index == state.queries.length + 1) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.medium),
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
                query: query,
                isOwnQuery: true,
                colorIndex: index - 1,
                onDelete: () =>
                    ref.read(myQueriesProvider.notifier).deleteQuery(query.id),
                onResolve: () =>
                    ref.read(myQueriesProvider.notifier).resolveQuery(query.id),
              );
            },
          ),
        );
      },
    );
  }
}
