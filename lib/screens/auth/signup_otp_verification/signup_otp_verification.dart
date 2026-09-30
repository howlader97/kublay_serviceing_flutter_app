import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/auth/role_setting_screen/provider/roll_settings_provider.dart';
import 'package:belwork/screens/auth/sign_in_screen/widgets/sign_in_header.dart';
import 'package:belwork/screens/auth/signup_otp_verification/provider/otp_verification_provider.dart';
import 'package:belwork/screens/auth/signup_otp_verification/provider/professional_otp_verification_provider.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_snack_bar.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class SignupOtpVerification extends ConsumerStatefulWidget {
  const SignupOtpVerification({super.key});

  @override
  ConsumerState<SignupOtpVerification> createState() => _SignupOtpVerificationState();
}

class _SignupOtpVerificationState extends ConsumerState<SignupOtpVerification> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  String _savedEmail = "";

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final email = await StorageServices.instance.getSignUpEmail();
    if (mounted) {
      setState(() {
        _savedEmail = email;
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpVerificationProvider);
    final proOtpState = ref.watch(professionalOtpVerificationProvider);

    final selectedRollIndex = ref.watch(rollSettingsProvider);
    final userRoleState = ref.watch(userRoleNotifierProvider);

    final isTechnician = selectedRollIndex == 1 ||
        (userRoleState.value != null &&
            (userRoleState.value!.toUpperCase() == "TECHNICIAN" ||
                userRoleState.value!.toUpperCase() == "PROFESSIONAL"));

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SignInHeader(),
                  Center(
                    child: AppText(
                      text: "Enter code",
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(height: 10),
                  AppText(
                    text: _savedEmail.isNotEmpty
                        ? "We sent code to $_savedEmail"
                        : "We sent code to your E-mail",
                    textAlign: TextAlign.center,
                  ),
                  const Gap(height: 20),
                  AppInputWidgetTwo(
                    title: "Code",
                    hintText: "12345",
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter OTP code";
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return "OTP code must be numbers";
                      }
                      return null;
                    },
                  ),
                  const Gap(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppText(
                        text: "If you didn't receive a code,",
                        fontSize: 12,
                      ),
                      const Gap(width: 8),
                      GestureDetector(
                        onTap: () async {
                          if (_savedEmail.isEmpty) {
                            AppSnackBar.instance.error("Email not found for resending OTP.");
                            return;
                          }
                          bool isSuccess = false;
                          if (isTechnician) {
                            isSuccess = await ref
                                .read(professionalOtpVerificationProvider.notifier)
                                .resendOtp(email: _savedEmail);
                          } else {
                            isSuccess = await ref
                                .read(otpVerificationProvider.notifier)
                                .resendOtp(email: _savedEmail);
                          }

                          if (isSuccess) {
                            AppSnackBar.instance.success("OTP sent to your email!");
                          }
                        },
                        child: AppText(
                          text: "Resend",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Gap(height: 20),
                  AppButton(
                    isLoading: otpState.isLoading || proOtpState.isLoading,
                    onTap: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      final otpStr = _otpController.text.trim();

                      bool isSuccess = false;
                      if (isTechnician) {
                        isSuccess = await ref
                            .read(professionalOtpVerificationProvider.notifier)
                            .verifyOtp(email: _savedEmail, otp: otpStr);
                      } else {
                        isSuccess = await ref
                            .read(otpVerificationProvider.notifier)
                            .verifyOtp(email: _savedEmail, otp: otpStr);
                      }

                      if (isSuccess) {
                        AppSnackBar.instance.success("Email verified successfully!");
                        await ref
                            .read(userRoleNotifierProvider.notifier)
                            .loadRole();

                        if (isTechnician) {
                          AppRoutes.instance.go(
                            AppRoutesKey.instance.verificationScreen,
                          );
                        } else {
                          AppRoutes.instance.go(
                            AppRoutesKey.instance.appNavigationScreen,
                          );
                        }
                      }
                    },
                    title: "Verify",
                    height: 50,
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
