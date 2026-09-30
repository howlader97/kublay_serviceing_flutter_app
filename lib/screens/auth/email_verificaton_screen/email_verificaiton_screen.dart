import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_asserts_icons_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/auth/email_verificaton_screen/provider/email_verification_provider.dart';
import 'package:belwork/screens/auth/sign_in_screen/widgets/sign_in_header.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(emailVerificationProvider.notifier)
          .sendOtp(email: _emailController.text.trim());

      if (success && mounted) {
        AppRoutes.instance
            .pushNamed(AppRoutesKey.instance.otpVerificationScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emailVerificationProvider);

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
                    text: "Restore Your Shield",
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(height: 10),
                const AppText(
                  text:
                      "Enter your registered email to receive a secure\n recovery code",
                  textAlign: TextAlign.center,
                ),
                const Gap(height: 20),
                AppInputWidgetTwo(
                  title: "E-mail",
                  controller: _emailController,
                  hintText: "a@gmail.com",
                  isEmail: true,
                  keyboardType: TextInputType.emailAddress,
                  prefix: Image.asset(
                    AppAssertsIconsPath.instance.mailPassword,
                    scale: 3,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter email";
                    }
                    if (!isValidEmail(value.trim())) {
                      return "Please provide a valid email address";
                    }
                    return null;
                  },
                ),
                const Gap(height: 30),
                AppButton(
                  onTap: _handleSendOtp,
                  title: "Send Code",
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
