import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/home/notifier/home_notifier.dart';
import 'package:air_query/ui/my_queries/notifier/my_queries_notifier.dart';
import 'package:air_query/ui/post_query/notifier/post_query_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostQueryScreen extends ConsumerStatefulWidget {
  const PostQueryScreen({super.key});

  @override
  ConsumerState<PostQueryScreen> createState() => _PostQueryScreenState();
}

class _PostQueryScreenState extends ConsumerState<PostQueryScreen> {
  final _descriptionController = TextEditingController();
  bool _postToAll = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Snackbar on error
    ref.listen(postQueryProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    });

    // On success — refresh feed + pop screen
    ref.listen(postQueryProvider.select((s) => s.success), (_, success) {
      if (success) {
        // refresh both (home and my feed) screens queries
        ref.read(homeProvider.notifier).refresh();
        ref.read(myQueriesProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Query posted!"),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Post a Query")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Description field
              TextField(
                controller: _descriptionController,
                maxLength: BusinessConstants.maxQueryLen,
                textInputAction: TextInputAction.done,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "What's your query?",
                  hintText: "e.g: How to submit fee Online?",
                  prefixIcon: Icon(Icons.help_outline),
                ),
              ),

              const SizedBox(height: AppSizes.medium),

              // Post to all campuses checkbox
              CheckboxListTile(
                value: _postToAll,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _postToAll = val ?? false),
                title: Text(
                  "Relevant to all campuses? Check to share everywhere.",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                controlAffinity: .leading,
              ),

              const SizedBox(height: AppSizes.vLarge),

              Text(
                  "Please Note that you can post ${BusinessConstants.maxQueriesPerDayPerUser} Queries per day! (inclusive deleted/resolved)",
                  textAlign: .center,
                  style: Theme.of(context).textTheme.bodySmall
              ),

              const SizedBox(height: AppSizes.medium),

              // Post button
              Consumer(
                builder: (context, ref, _) {
                  final isLoading = ref.watch(
                    postQueryProvider.select((s) => s.isLoading),
                  );
                  return CTAButton(
                    text: "Post Query",
                    onPressed: _onPost,
                    isLoading: isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPost() {
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please describe your query.")),
      );
      return;
    }

    if (description.length < BusinessConstants.minQueryLen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Query must be at least ${BusinessConstants.minQueryLen} characters.",
          ),
        ),
      );
      return;
    }

    ref
        .read(postQueryProvider.notifier)
        .postQuery(description: description, postToAllCampuses: _postToAll);
  }
}
