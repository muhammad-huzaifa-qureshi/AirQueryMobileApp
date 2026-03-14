import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/models/query_model.dart';
import 'package:air_query/ui/responses/notifier/responses_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/response_card.dart';

class ResponsesScreen extends ConsumerStatefulWidget {
  final QueryModel query;

  const ResponsesScreen({super.key, required this.query});

  @override
  ConsumerState<ResponsesScreen> createState() => _QueryDetailScreenState();
}

class _QueryDetailScreenState extends ConsumerState<ResponsesScreen> {
  final _scrollController = ScrollController();
  final _responseController = TextEditingController();
  late final String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = ref
        .read(responsesProvider(widget.query.id).notifier)
        .currentUserID;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(responsesProvider(widget.query.id).notifier).fetchMore();
    }
  }

  void _onPost() {
    final description = _responseController.text.trim();
    if (description.isEmpty) return;

    if (description.length < BusinessConstants.minResponseLen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Response must be at least ${BusinessConstants.minResponseLen} characters.",
          ),
        ),
      );
      return;
    }
    _responseController.clear();
    ref
        .read(responsesProvider(widget.query.id).notifier)
        .postResponse(description);
  }

  @override
  Widget build(BuildContext context) {
    // Snackbar on error
    ref.listen(responsesProvider(widget.query.id).select((s) => s.error), (
      _,
      error,
    ) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Responses")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody()),
            _buildResponseInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(responsesProvider(widget.query.id));

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.responses.isEmpty && state.error == null) {
          return Center(child: Text("Be the first to respond the query!"));
        }

        if (state.responses.isEmpty && state.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Failed to load responses."),
                const SizedBox(height: AppSizes.small),
                ElevatedButton(
                  onPressed: () => ref
                      .read(responsesProvider(widget.query.id).notifier)
                      .fetchInitial(),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        // normal state
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(responsesProvider(widget.query.id).notifier).refresh(),
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const .all(AppSizes.medium),
            itemCount: state.responses.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Bottom loader
              if (index == state.responses.length) {
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

              final response = state.responses[index];
              final isOwn = response.postedByUid == _currentUserId;

              return ResponseCard(
                response: response,
                isOwn: isOwn,
                onDelete: isOwn
                    ? () => ref
                          .read(responsesProvider(widget.query.id).notifier)
                          .deleteResponse(response.id)
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildResponseInput() {
    return Consumer(
      builder: (context, ref, _) {
        final isPosting = ref.watch(
          responsesProvider(widget.query.id).select((s) => s.isLoading),
        );

        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            left: AppSizes.medium,
            right: AppSizes.medium,
            top: AppSizes.medium,
            bottom: bottomInset > 0 ? bottomInset : AppSizes.medium,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _responseController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _onPost(),
                  maxLength: BusinessConstants.maxResponseLen,
                  decoration: const InputDecoration(
                    hintText: "Write a response...",
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.small),
              IconButton(
                onPressed: isPosting ? null : _onPost,
                icon: const Icon(
                  Icons.send_outlined,
                  size: AppSizes.mediumIcon,
                ),
                tooltip: "send",
                color: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}
