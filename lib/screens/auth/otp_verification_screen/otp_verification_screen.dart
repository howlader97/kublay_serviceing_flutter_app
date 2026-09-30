import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/auth/otp_verification_screen/provider/otp_verification_provider.dart';
import 'package:belwork/screens/auth/sign_in_screen/widgets/sign_in_header.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = "";

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final email = await StorageServices.instance.getForgotPasswordEmail();
    if (mounted) {
      setState(() {
        _email = email;
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(otpVerificationProvider.notifier)
          .verifyOtp(
            otp: _otpController.text.trim(),
            email: _email.isNotEmpty ? _email : null,
          );

      if (success && mounted) {
        AppRoutes.instance
            .pushNamed(AppRoutesKey.instance.resetPasswordScreen);
      }
    }
  }

  Future<void> _handleResendOtp() async {
    await ref
        .read(otpVerificationProvider.notifier)
        .resendOtp(email: _email.isNotEmpty ? _email : null);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otpVerificationProvider);

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
                    text: "Enter code",
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(height: 10),
                AppText(
                  text: _email.isNotEmpty
                      ? "We sent code to $_email"
                      : "We sent code to your E-mail",
                  textAlign: TextAlign.center,
                ),
                const Gap(height: 20),
                AppInputWidgetTwo(
                  title: "Code",
                  controller: _otpController,
                  hintText: "123456",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter the OTP code";
                    }
                    return null;
                  },
                ),
                const Gap(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const AppText(
                      text: "If you didn't receive a code, ",
                      fontSize: 12,
                    ),
                    GestureDetector(
                      onTap: state.isLoading ? null : _handleResendOtp,
                      child: const AppText(
                        text: "Resend",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Gap(height: 20),
                AppButton(
                  onTap: _handleVerifyOtp,
                  title: "Verify",
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
