import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/company_employee_profile_model.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/screens/company_employee_screen/company_profile_edit_screen/provider/company_profile_edit_provider.dart';
import 'package:belwork/screens/company_employee_screen/company_profile_screen/provider/company_employee_profile_provider.dart';
import 'package:belwork/utils/app_snack_bar.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image_circular.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/image_userPick/image_user_pick.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CompanyProfileEditScreen extends ConsumerStatefulWidget {
  const CompanyProfileEditScreen({super.key});

  @override
  ConsumerState<CompanyProfileEditScreen> createState() =>
      _CompanyProfileEditScreenState();
}

class _CompanyProfileEditScreenState
    extends ConsumerState<CompanyProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedAvatarPath;
  String _currentAvatarUrl = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = ref.read(companyEmployeeProfileProvider);
      if (profileState.profileResponse == null) {
        ref
            .read(companyEmployeeProfileProvider.notifier)
            .fetchProfile(showLoading: false);
      } else {
        _populateProfileData(profileState.profileResponse?.data?.user);
        setState(() {});
      }
    });
  }

  void _populateProfileData(CompanyEmployeeUser? user) {
    if (user != null) {
      if (!_isInitialized || _nameController.text.isEmpty) {
        _nameController.text = user.name ?? '';
      }
      _currentAvatarUrl = user.avatar ?? '';
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(companyProfileEditProvider);

    ref.listen<CompanyEmployeeProfileState>(
      companyEmployeeProfileProvider,
      (previous, next) {
        if (next.profileResponse?.data?.user != null) {
          _populateProfileData(next.profileResponse?.data?.user);
          if (mounted) {
            setState(() {});
          }
        }
      },
    );

    final profileState = ref.watch(companyEmployeeProfileProvider);
    if (!_isInitialized && profileState.profileResponse?.data?.user != null) {
      _populateProfileData(profileState.profileResponse?.data?.user);
    }

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
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
                      text: "Edit Profile",
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: AppColors.instance.bodyText,
                    ),
                  ],
                ),
                const Gap(height: 30),

                // Avatar Container with Camera Icon at Bottom-Right
                Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipOval(
                          child: Container(
                            width: 100,
                            height: 100,
                            color: AppColors.instance.containerBackground,
                            child: (_selectedAvatarPath != null &&
                                    _selectedAvatarPath!.isNotEmpty)
                                ? Image.file(
                                    File(_selectedAvatarPath!),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : AppImageCircular(
                                    height: 100,
                                    width: 100,
                                    url: _currentAvatarUrl.isNotEmpty
                                        ? _currentAvatarUrl
                                        : 'https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg?w=768',
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: GestureDetector(
                            onTap: () {
                              appImageUserTake(callBack: (path) {
                                if (path.isNotEmpty) {
                                  setState(() {
                                    _selectedAvatarPath = path;
                                  });
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.all(7),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: AppColors.instance.textColor14,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(height: 30),

                // Name Input Field
                AppInputWidgetTwo(
                  controller: _nameController,
                  title: "Name",
                  hintText: "Enter name",
                ),
                const Gap(height: 30),

                // Save Changes Button
                AppButton(
                  title: "Save Changes",
                  height: 48,
                  isLoading: editState.isLoading,
                  backgroundColor: AppColors.instance.primary,
                  titleColor: Colors.white,
                  onTap: () async {
                    final name = _nameController.text.trim();

                    final isSuccess = await ref
                        .read(companyProfileEditProvider.notifier)
                        .updateProfile(
                          name: name,
                          avatarPath: _selectedAvatarPath,
                        );

                    if (isSuccess) {
                      AppSnackBar.instance.success("Profile updated successfully!");
                      if (_currentAvatarUrl.isNotEmpty) {
                        try {
                          await CachedNetworkImage.evictFromCache(_currentAvatarUrl);
                          await CustomCacheManager.instance.removeFile(_currentAvatarUrl);
                        } catch (_) {}
                      }
                      await ref
                          .read(companyEmployeeProfileProvider.notifier)
                          .fetchProfile(showLoading: false);
                      if (mounted) {
                        AppRoutes.instance.pop();
                      }
                    }
                  },
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
