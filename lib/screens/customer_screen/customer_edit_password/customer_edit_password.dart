import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_asserts_icons_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/screens/customer_screen/customer_edit_password/provider/customer_edit_password_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerEditPassword extends ConsumerStatefulWidget {
  const CustomerEditPassword({super.key});

  @override
  ConsumerState<CustomerEditPassword> createState() =>
      _CustomerEditPasswordState();
}

class _CustomerEditPasswordState extends ConsumerState<CustomerEditPassword> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(customerEditPasswordProvider.notifier)
          .resetPassword(
            oldPassword: _oldPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          );

      if (success && mounted) {
        AppRoutes.instance.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(customerEditPasswordProvider);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Form(
              key: _formKey,
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
                        text: "Password Manage",
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: AppColors.instance.bodyText,
                      ),
                    ],
                  ),
                  const Gap(height: 40),

                  AppInputWidgetTwo(
                    controller: _oldPasswordController,
                    title: "Old Password",
                    hintText: "******",
                    prefix: Image.asset(
                      AppAssertsIconsPath.instance.lockPassword,
                      scale: 3,
                    ),
                    isPassWord: true,
                    maxLines: 1,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter old password";
                      }
                      return null;
                    },
                  ),
                  AppInputWidgetTwo(
                    controller: _newPasswordController,
                    title: "New Password",
                    hintText: "*****",
                    prefix: Image.asset(
                      AppAssertsIconsPath.instance.lockPassword,
                      scale: 3,
                    ),
                    isPassWord: true,
                    maxLines: 1,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter new password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),

                  AppInputWidgetTwo(
                    controller: _confirmPasswordController,
                    title: "Confirm Password",
                    hintText: "*****",
                    prefix: Image.asset(
                      AppAssertsIconsPath.instance.lockPassword,
                      scale: 3,
                    ),
                    isPassWord: true,
                    maxLines: 1,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please confirm your new password";
                      }
                      if (value != _newPasswordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),

                  const Gap(height: 20),
                  AppButton(
                    title: "Save Changes",
                    height: 48,
                    isLoading: isLoading,
                    onTap: _handleSaveChanges,
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
