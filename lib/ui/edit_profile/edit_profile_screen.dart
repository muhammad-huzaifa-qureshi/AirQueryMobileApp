import 'package:air_query/core/constants/app_sizes.dart';
import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/core/constants/campuses.dart';
import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/core/widgets/cta_button.dart';
import 'package:air_query/ui/profile/notifier/profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notifier/edit_profile_notifier.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  String? _selectedCampus;
  String? _selectedSemester;

  final _semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];

  @override
  void initState() {
    super.initState();
    // Pre-fill
    final user = ref.read(profileProvider).user;
    if (user != null) {
      _nameController.text = user.name;
      _selectedCampus = user.campus.isNotEmpty ? user.campus : null;
      _selectedSemester = user.semester.isNotEmpty ? user.semester : null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Snackbar on error
    ref.listen(editProfileProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    });

    // Navigate back on success + refresh profile, show snackbar
    ref.listen(editProfileProvider.select((s) => s.success), (_, success) {
      if (success) {
        ref.read(profileProvider.notifier).fetchProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profile Updated!"),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                keyboardType: TextInputType.name,
                textInputAction: .next,
              ),

              const SizedBox(height: AppSizes.medium),

              // Campus dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCampus,
                hint: const Text("Select Campus"),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.school_outlined),
                ),
                items: Campuses.list
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCampus = val),
              ),

              const SizedBox(height: AppSizes.medium),

              // Semester dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedSemester,
                hint: const Text("Select Semester"),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.layers_outlined),
                ),
                items: _semesters
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text("Semester $s"),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedSemester = val),
              ),

              const SizedBox(height: AppSizes.vLarge),

              Text(
                "Note: Name can be changed only once every ${BusinessConstants.nameChangeCooldownDays} days.",
                textAlign: .center,
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const SizedBox(height: AppSizes.medium),

              // Save button
              Consumer(
                builder: (context, ref, child) {
                  final isLoading = ref.watch(
                    editProfileProvider.select((value) => value.isLoading),
                  );
                  return CTAButton(
                    text: "Save",
                    onPressed: _onSave,
                    isLoading: isLoading ? true : false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    final name = _nameController.text.trim();

    if (name.isEmpty || _selectedCampus == null || _selectedSemester == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    if (name.length < BusinessConstants.nameMinChars) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Name must contain at least ${BusinessConstants.nameMinChars} characters!",
          ),
        ),
      );
      return;
    }

    if (name.length > BusinessConstants.nameMaxChars) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Name must not exceed ${BusinessConstants.nameMaxChars} characters!",
          ),
        ),
      );
      return;
    }

    // Check if anything actually changed
    final user = ref.read(profileProvider).user;
    if (user != null &&
        user.name == name &&
        user.campus == _selectedCampus &&
        user.semester == _selectedSemester) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No changes to save.")));
      return;
    }

    ref
        .read(editProfileProvider.notifier)
        .updateProfile(
          name: name,
          campus: _selectedCampus!,
          semester: _selectedSemester!,
        );
  }
}
