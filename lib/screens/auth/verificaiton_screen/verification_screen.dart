import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/auth/sign_in_screen/widgets/sign_in_header.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String _savedEmail = "";

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final email = await StorageServices.instance.getSignUpEmail();
    if (mounted && email.isNotEmpty) {
      setState(() {
        _savedEmail = email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              const SignInHeader(),
              const Gap(height: 10),

              // Animated/Highlighted Icon Container
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.instance.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.instance.primary.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.instance.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.instance.primary.withValues(
                            alpha: 0.35,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
              ),
              const Gap(height: 24),

              // Title
              AppText(
                text: "Verification Pending",
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.instance.textColor,
                textAlign: TextAlign.center,
              ),
              const Gap(height: 12),

              // Subtitle
              AppText(
                text:
                    "Your technician registration has been submitted successfully and is currently under review by our admin team.",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.instance.gray4B,
                textAlign: TextAlign.center,
              ),
              const Gap(height: 24),

              // Information Card with Steps
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFEBE6E8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFBE00,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Color(0xFFD48806),
                            size: 20,
                          ),
                        ),
                        const Gap(width: 10),
                        Expanded(
                          child: AppText(
                            text: "What happens next?",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.instance.textColor,
                          ),
                        ),
                      ],
                    ),
                    const Gap(height: 16),
                    const Divider(height: 1, color: Color(0xFFF0ECEE)),
                    const Gap(height: 16),

                    _buildStepItem(
                      stepNumber: "1",
                      title: "Admin Review",
                      description:
                          "Our admin team will verify your provided information and credentials.",
                      icon: Icons.fact_check_outlined,
                    ),
                    const Gap(height: 14),

                    _buildStepItem(
                      stepNumber: "2",
                      title: "Email Notification",
                      description: _savedEmail.isNotEmpty
                          ? "Once approved, a confirmation email will be sent to $_savedEmail."
                          : "Once approved, a confirmation email will be sent to your registered email address.",
                      icon: Icons.mail_outline_rounded,
                    ),
                    const Gap(height: 14),

                    _buildStepItem(
                      stepNumber: "3",
                      title: "Login & Start Working",
                      description:
                          "After receiving the verification email, you will be able to start receiving job requests.",
                      icon: Icons.login_rounded,
                    ),
                  ],
                ),
              ),
              const Gap(height: 20),

              // Helper Notice Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF34C759).withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF27AE60),
                      size: 20,
                    ),
                    const Gap(width: 10),
                    Expanded(
                      child: AppText(
                        text:
                            "Please check your inbox (including spam folder) regularly for your approval email.",
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E7E34),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(height: 28),

              // Back to Sign In Button
              AppButton(
                onTap: () {
                  AppRoutes.instance.go(AppRoutesKey.instance.signInScreen);
                },
                title: "Back to Sign In",
                backgroundColor: AppColors.instance.primary,
                titleColor: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                borderRadius: BorderRadius.circular(12),
                height: 50,
              ),
              const Gap(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.instance.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(icon, color: AppColors.instance.primary, size: 18),
          ),
        ),
        const Gap(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: title,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.instance.textColor,
              ),
              const Gap(height: 3),
              AppText(
                text: description,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.instance.gray4B,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
