import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:belwork/constant/app_asserts_icons_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/service_category_response.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/auth/role_setting_screen/provider/roll_settings_provider.dart';
import 'package:belwork/screens/auth/sign_up_screen/provider/professional_sign_up_provider.dart';
import 'package:belwork/screens/auth/sign_up_screen/provider/sign_up_provider.dart';
import 'package:belwork/screens/customer_screen/customer_home_screen/provider/service_category_provider.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_snack_bar.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/drop_down.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _corporateVatController = TextEditingController();

  String? _selectedSchedule = "AVAILABLE_WEEKDAYS";
  ServiceCategoryModel? _selectedCategory;
  File? _cbeSecurityFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _corporateVatController.dispose();
    super.dispose();
  }

  Future<void> _pickSecurityFile(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          _cbeSecurityFile = File(picked.path);
        });
      }
    } catch (e) {
      AppSnackBar.instance.error("Failed to pick file: $e");
    }
  }

  void _showFilePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.instance.containerBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: "Upload CBE Security File",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.instance.textColor,
                ),
                const Gap(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _pickSecurityFile(ImageSource.camera);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.instance.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.instance.primary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: AppColors.instance.primary,
                              ),
                              const Gap(height: 8),
                              const AppText(
                                text: "Camera",
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _pickSecurityFile(ImageSource.gallery);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.instance.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.instance.primary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 40,
                                color: AppColors.instance.primary,
                              ),
                              const Gap(height: 8),
                              const AppText(
                                text: "Gallery / Files",
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvailabilityOption({
    required String label,
    required String value,
  }) {
    final bool isSelected = _selectedSchedule == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSchedule = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: isSelected,
            activeColor: AppColors.instance.primary,
            checkColor: Colors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.instance.primary
                  : AppColors.instance.textColor.withValues(alpha: 0.5),
            ),
            onChanged: (val) {
              if (val == true) {
                setState(() {
                  _selectedSchedule = value;
                });
              }
            },
          ),
          const Gap(width: 8),
          AppText(
            text: label,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: AppColors.instance.textColor,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpProvider);
    final proSignUpState = ref.watch(professionalSignUpProvider);
    final categoriesState = ref.watch(serviceCategoryProvider);

    final selectedRollIndex = ref.watch(rollSettingsProvider);
    final userRoleState = ref.watch(userRoleNotifierProvider);

    final isTechnician =
        selectedRollIndex == 1 ||
        (userRoleState.value != null &&
            userRoleState.value!.toUpperCase() == "TECHNICIAN");

    final categoriesList = categoriesState.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Center(
                    child: AppText(
                      text: "Your daily helper",
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(height: 10),
                  const AppText(
                    text: "Daily house work management\n made simple",
                    textAlign: TextAlign.center,
                  ),
                  const Gap(height: 30),
                  AppInputWidgetTwo(
                    title: "E-mail",
                    controller: _emailController,
                    hintText: "Enter your mail",
                    prefix: Image.asset(
                      AppAssertsIconsPath.instance.mailPassword,
                      scale: 3,
                    ),
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter email";
                      }
                      if (!isValidEmail(value.trim())) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  AppInputWidgetTwo(
                    title: "Full Name",
                    controller: _nameController,
                    hintText: "Enter full name",
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter full name";
                      }
                      return null;
                    },
                  ),
                  if (isTechnician) ...[
                    AppInputWidgetTwo(
                      title: "Corporate VAT Number",
                      controller: _corporateVatController,
                      hintText: "Enter corporate VAT number",
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter corporate VAT";
                        }
                        return null;
                      },
                    ),
                    const Gap(height: 15),

                    // Category Dropdown for Technician
                    DropdownField<ServiceCategoryModel>(
                      title: "Category *",
                      hintText: "Select Category",
                      options: categoriesList,
                      value: _selectedCategory,
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      },
                      itemLabel: (item) => item.name ?? "",
                      padding: EdgeInsets.zero,
                    ),
                    Gap(height: 14,),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: "Availability",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.instance.textColor,
                          ),
                          const Gap(height: 8),
                          Transform.translate(
                            offset: const Offset(-4, 0),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _buildAvailabilityOption(
                                  label: "Available Weekdays",
                                  value: "AVAILABLE_WEEKDAYS",
                                ),
                                _buildAvailabilityOption(
                                  label: "Available Weekends",
                                  value: "AVAILABLE_WEEKENDS",
                                ),
                                _buildAvailabilityOption(
                                  label: "Available Full Week",
                                  value: "AVAILABLE_FULL_WEEK",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(height: 15),

                    // CBE Security File Upload Box
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppText(
                              text: "CBE Security File",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.instance.textColor,
                            ),
                            const Gap(width: 6),
                            AppText(
                              text: "(Optional)",
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.instance.gray500,
                            ),
                          ],
                        ),
                        const Gap(height: 6),
                        GestureDetector(
                          onTap: _showFilePickerModal,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.instance.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.instance.textColor,
                                width: 1,
                              ),
                            ),
                            child: _cbeSecurityFile != null
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.file_present_rounded,
                                        color: AppColors.instance.primary,
                                        size: 28,
                                      ),
                                      const Gap(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AppText(
                                              text: _cbeSecurityFile!.path
                                                  .split(
                                                    Platform.isWindows
                                                        ? '\\'
                                                        : '/',
                                                  )
                                                  .last,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  AppColors.instance.textColor,
                                            ),
                                            const AppText(
                                              text: "File selected",
                                              fontSize: 12,
                                              color: Colors.green,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _cbeSecurityFile = null;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppText(
                                        text:
                                            "Upload CBE Security File",
                                        fontSize: 14,
                                        color: AppColors.instance.gray500,
                                      ),
                                      Icon(
                                        Icons.upload_file,
                                        color: AppColors.instance.primary,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(height: 4),
                  ],
                  AppInputWidgetTwo(
                    title: "Password",
                    controller: _passwordController,
                    hintText: "Enter Password",
                    prefix: Image.asset(
                      AppAssertsIconsPath.instance.lockPassword,
                      scale: 3,
                    ),
                    isPassWord: true,
                    maxLines: 1,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  AppInputWidgetTwo(
                    title: "Confirm Password",
                    controller: _confirmPasswordController,
                    hintText: "Enter Password",
                    prefix: Image.asset(
                      AppAssertsIconsPath.instance.lockPassword,
                      scale: 3,
                    ),
                    isPassWord: true,
                    maxLines: 1,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm password";
                      }
                      if (value != _passwordController.text) {
                        return "Passwords don't match";
                      }
                      return null;
                    },
                  ),
                  const Gap(height: 20),
                  AppButton(
                    isLoading:
                        signUpState.isLoading || proSignUpState.isLoading,
                    onTap: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      final name = _nameController.text.trim();
                      final email = _emailController.text.trim().toLowerCase();
                      final password = _passwordController.text.trim();

                      bool isSuccess = false;
                      if (isTechnician) {
                        if (_selectedCategory == null ||
                            (_selectedCategory?.id?.isEmpty ?? true)) {
                          AppSnackBar.instance.error(
                            "Please select a category",
                          );
                          return;
                        }

                        final corporateVatNumber = _corporateVatController.text
                            .trim();
                        final availability =
                            _selectedSchedule ?? "AVAILABLE_WEEKDAYS";
                        final categoryId = _selectedCategory!.id!;

                        isSuccess = await ref
                            .read(professionalSignUpProvider.notifier)
                            .signUp(
                              name: name,
                              email: email,
                              password: password,
                              corporateVatNumber: corporateVatNumber,
                              availability: availability,
                              categories: categoryId,
                              cbeSecurityFilePath: _cbeSecurityFile?.path,
                            );
                      } else {
                        isSuccess = await ref
                            .read(signUpProvider.notifier)
                            .signUp(
                              name: name,
                              email: email,
                              password: password,
                            );
                      }

                      if (isSuccess) {
                        await StorageServices.instance.setSignUpEmail(email);
                        AppSnackBar.instance.success("Sign up successful!");

                        AppRoutes.instance.pushNamed(
                          AppRoutesKey.instance.signupOtpVerification,
                        );
                      }
                    },
                    title: "Create an Account",
                    height: 50,
                  ),
                  const Gap(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppText(
                        text: "Already have an account ?",
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                      const Gap(width: 10),
                      GestureDetector(
                        onTap: () {
                          AppRoutes.instance.pushNamed(
                            AppRoutesKey.instance.signInScreen,
                          );
                        },
                        child: const AppText(
                          text: "Sign In",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
