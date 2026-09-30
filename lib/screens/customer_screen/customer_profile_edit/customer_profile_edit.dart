import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_asserts_icons_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/screens/customer_screen/customer_profile_edit/provider/customer_profile_edit_provider.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/provider/customer_profile_provider.dart';
import 'package:belwork/utils/app_snack_bar.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image_circular.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/image_userPick/image_user_pick.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerProfileEdit extends ConsumerStatefulWidget {
  const CustomerProfileEdit({super.key});

  @override
  ConsumerState<CustomerProfileEdit> createState() =>
      _CustomerProfileEditState();
}

class _CustomerProfileEditState extends ConsumerState<CustomerProfileEdit> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String? _avatarPath;
  bool _isPreFilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _onSaveChanges() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();
    final contact = _contactController.text.trim();

    if (name.isEmpty &&
        email.isEmpty &&
        address.isEmpty &&
        contact.isEmpty &&
        (_avatarPath == null || _avatarPath!.isEmpty)) {
      AppSnackBar.instance.error("Please enter at least one detail to update");
      return;
    }

    final success =
        await ref.read(customerProfileEditProvider.notifier).updateProfile(
              name: name.isNotEmpty ? name : null,
              email: email.isNotEmpty ? email : null,
              address: address.isNotEmpty ? address : null,
              contact: contact.isNotEmpty ? contact : null,
              avatarPath: _avatarPath,
            );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final editState = ref.watch(customerProfileEditProvider);
    final isSubmitting = editState.isLoading;

    const String defaultAvatar =
        "https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg?w=768";

    // Auto pre-fill inputs from logged in user profile
    if (!_isPreFilled && profileAsync.hasValue) {
      final user = profileAsync.value;
      if (user != null) {
        _nameController.text = user.name ?? '';
        _emailController.text = user.email ?? '';
        _addressController.text = user.address ?? '';
        _contactController.text = user.contact ?? '';
        _isPreFilled = true;
      }
    }

    final currentAvatarUrl = profileAsync.value?.avatar ?? defaultAvatar;

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BackButtonWidget(
                      onTap: () {
                        AppRoutes.instance.pop();
                      },
                    ),
                    const Gap(width: 12),
                    AppText(
                      text: "Personal details",
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: AppColors.instance.bodyText,
                    ),
                  ],
                ),
                const Gap(height: 30),

                // Avatar Image Container with Camera Icon Picker
                Center(
                  child: Stack(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 100,
                          height: 100,
                          color: AppColors.instance.containerBackground,
                          child: (_avatarPath != null &&
                                  _avatarPath!.isNotEmpty &&
                                  !_avatarPath!.startsWith('http'))
                              ? Image.file(
                                  File(_avatarPath!),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : AppImageCircular(
                                  height: 100,
                                  width: 100,
                                  url: currentAvatarUrl,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(220),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: GestureDetector(
                            onTap: () {
                              appImageUserTake(callBack: (path) {
                                setState(() {
                                  _avatarPath = path;
                                });
                              });
                            },
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.instance.black200,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(height: 20),

                // Full Name Input
                AppInputWidgetTwo(
                  controller: _nameController,
                  title: "Full Name",
                  hintText: "Enter full name",
                ),

                // E-mail Input
                AppInputWidgetTwo(
                  controller: _emailController,
                  title: "E-mail",
                  hintText: "Enter your mail",
                  prefix: Image.asset(
                    AppAssertsIconsPath.instance.mailPassword,
                    scale: 3,
                  ),
                ),

                // Address Input
                AppInputWidgetTwo(
                  controller: _addressController,
                  title: "Address",
                  hintText: "Enter address",
                  prefix: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.instance.textColor14,
                  ),
                ),

                // Mobile Input
                AppInputWidgetTwo(
                  controller: _contactController,
                  title: "Mobile",
                  hintText: "Enter mobile number",
                  prefix: Icon(
                    Icons.call_outlined,
                    color: AppColors.instance.textColor14,
                  ),
                ),
                const Gap(height: 20),

                // Save Changes Button
                AppButton(
                  title: isSubmitting ? "Saving..." : "Save Changes",
                  height: 48,
                  backgroundColor: isSubmitting
                      ? AppColors.instance.gray500
                      : AppColors.instance.primary,
                  titleColor: Colors.white,
                  onTap: isSubmitting ? null : _onSaveChanges,
                ),
                const Gap(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
