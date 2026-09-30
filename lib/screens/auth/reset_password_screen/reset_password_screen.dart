import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_asserts_icons_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/auth/reset_password_screen/provider/reset_password_provider.dart';
import 'package:belwork/screens/auth/sign_in_screen/widgets/sign_in_header.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(resetPasswordProvider.notifier)
          .updatePassword(
            newPassword: _passwordController.text.trim(),
            confirmPassword: _confirmPasswordController.text.trim(),
          );

      if (success && mounted) {
        AppRoutes.instance.goNamed(AppRoutesKey.instance.signInScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordProvider);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SignInHeader(),
                const Center(
                  child: AppText(
                    text: "Create new password",
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(height: 10),
                const AppText(
                  text:
                      "Keep your account safe with a unique numeric\n password",
                  textAlign: TextAlign.center,
                ),
                const Gap(height: 20),
                AppInputWidgetTwo(
                  controller: _passwordController,
                  title: "Password",
                  hintText: "Enter new password",
                  maxLines: 1,
                  isPassWord: true,
                  prefix: Image.asset(
                    AppAssertsIconsPath.instance.lockPassword,
                    scale: 3,
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter password";
                    }
                    if (value.trim().length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                AppInputWidgetTwo(
                  controller: _confirmPasswordController,
                  title: "Confirm Password",
                  hintText: "Re-enter new password",
                  maxLines: 1,
                  isPassWord: true,
                  isPassWordSecondValidation: true,
                  isPassWordSecondValidationController: _passwordController,
                  prefix: Image.asset(
                    AppAssertsIconsPath.instance.lockPassword,
                    scale: 3,
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please confirm your password";
                    }
                    if (value.trim() != _passwordController.text.trim()) {
                      return "Both passwords must match";
                    }
                    return null;
                  },
                ),
                const Gap(height: 30),
                AppButton(
                  onTap: _handleUpdatePassword,
                  title: "Update Password",
                  isLoading: state.isLoading,
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
