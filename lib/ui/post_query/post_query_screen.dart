import 'dart:convert';
import 'dart:io';
import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/home/notifier/home_notifier.dart';
import 'package:air_query/ui/my_queries/notifier/my_queries_notifier.dart';
import 'package:air_query/ui/post_query/notifier/post_query_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class PostQueryScreen extends ConsumerStatefulWidget {
  const PostQueryScreen({super.key});

  @override
  ConsumerState<PostQueryScreen> createState() => _PostQueryScreenState();
}

class _PostQueryScreenState extends ConsumerState<PostQueryScreen> {
  final _descriptionController = TextEditingController();
  bool _postToAll = false;
  File? _pickedImage;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: BusinessConstants.queryImageQuality,
      maxWidth: BusinessConstants.maxQueryImageWidth,
    );
    if (picked != null) setState(() => _pickedImage = File(picked.path));
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
                textInputAction: TextInputAction.newline,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: "What's your query?",
                  hintText: "e.g: How to submit fee Online?",
                  prefixIcon: Icon(Icons.help_outline),
                ),
              ),

              const SizedBox(height: AppSizes.medium),

              // Image picker
              Row(
                mainAxisAlignment: .center,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(
                        Icons.image_outlined,
                        color: AppColors.whitish,
                      ),
                      label: Text(
                        _pickedImage == null ? "Attach Image (Max. ${BusinessConstants.maxQueryImageSizeMB}MB)" : "Replace",
                        style: TextStyle(color: AppColors.whitish),
                      ),
                    ),
                  ),
                  if (_pickedImage != null) ...[
                    const SizedBox(width: AppSizes.small),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.small),
                          child: Image.file(
                            _pickedImage!,
                            height: 50,
                            width: 50,
                            fit: .cover,
                          ),
                        ),
                        Positioned(
                          top: -15,
                          right: -15,
                          child: IconButton(
                            icon: Icon(
                              Icons.cancel,
                              size: AppSizes.mediumIcon,
                              color: AppColors.error,
                            ),
                            onPressed: () =>
                                setState(() => _pickedImage = null),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              SizedBox(height: AppSizes.small,),

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
                "Note: You can post ${BusinessConstants.maxQueriesPerDayPerUser} ${BusinessConstants.maxQueriesPerDayPerUser == 1 ? "query" : "queries"} per day, including deleted or resolved ones.",
                textAlign: .center,
                style: Theme.of(context).textTheme.bodySmall,
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

    String? base64Image;
    if (_pickedImage != null) {
      base64Image = base64Encode(_pickedImage!.readAsBytesSync());
    }

    ref
        .read(postQueryProvider.notifier)
        .postQuery(
          description: description,
          postToAllCampuses: _postToAll,
          base64Image: base64Image,
        );
  }
}
