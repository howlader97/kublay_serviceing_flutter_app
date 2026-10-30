import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_asserts_icons_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'provider/delete_account_provider.dart';

class CustomerDeleteAccountForm extends ConsumerStatefulWidget {
  const CustomerDeleteAccountForm({super.key});

  @override
  ConsumerState<CustomerDeleteAccountForm> createState() =>
      _CustomerDeleteAccountFormState();
}

class _CustomerDeleteAccountFormState
    extends ConsumerState<CustomerDeleteAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleDeleteAccount() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(deleteAccountProvider.notifier)
          .deleteAccount(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (success && mounted) {
        AppRoutes.instance.go(AppRoutesKey.instance.signInScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deleteState = ref.watch(deleteAccountProvider);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SingleChildScrollView(
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
                        text: "Delete account",
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: AppColors.instance.bodyText,
                      ),
                    ],
                  ),
                  const Gap(height: 30),
                  Center(
                    child: AppText(
                      text: "Log in to confirm",
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: AppColors.instance.bodyText,
                    ),
                  ),
                  const Gap(height: 10),
                  Center(
                    child: AppText(
                      text:
                          "Enter the login information for your\n account to confirm deletion.",
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.instance.bodyText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Gap(height: 20),
                  AppInputWidgetTwo(
                    title: "E-mail",
                    maxLines: 1,
                    hintText: "Enter your mail",
                    controller: _emailController,
                    isEmail: true,
                    validator: (String? value){
                      if(value?.isEmpty ?? true){
                        return "Enter your mail";
                      }
                      return null;
                    },
                    prefix: Image.asset(
                      AppAssertsIconsPath.instance.mailPassword,
                      scale: 3,
                    ),
                  ),
                  AppInputWidgetTwo(
                    title: "Password",
                    hintText: "Enter your password",
                    maxLines: 1,
                    controller: _passwordController,
                    isPassWord: true,
                    validator: (String? value){
                      if(value?.isEmpty ?? true){
                        return "Enter your password";
                      }
                      return null;
                    },
                    prefix: Image.asset(
                      AppAssertsIconsPath.instance.lockPassword,
                      scale: 3,
                    ),
                  ),
                  const Gap(height: 20),
                  AppButton(
                    onTap: _handleDeleteAccount,
                    isLoading: deleteState.isLoading,
                    title: "Continue to Delete Account",
                    height: 48,
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
