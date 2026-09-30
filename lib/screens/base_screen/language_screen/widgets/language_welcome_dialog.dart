import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/auth/role_setting_screen/provider/roll_settings_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageWelcomeDialog extends ConsumerWidget {
  const LanguageWelcomeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.instance.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => AppRoutes.instance.pop(),
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.instance.containerBackground
                          .withValues(alpha: 0.6),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.instance.gray500,
                    ),
                  ),
                ),
              ),

              // Gorgeous Header Icon with Glow Circle
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.instance.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.instance.primary.withValues(alpha: 0.18),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.instance.primary,
                        AppColors.instance.red73,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.instance.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.waving_hand_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const Gap(height: 18),

              // Title & Subtitle
              AppText(
                text: "Welcome to Belwork",
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.instance.textColor,
                textAlign: TextAlign.center,
              ),
              const Gap(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: AppText(
                  text:
                      "Choose how you'd like to continue and explore our services",
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.instance.gray500,
                  textAlign: TextAlign.center,
                ),
              ),
              const Gap(height: 24),

              // Option 1: Guest Card
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    await ref
                        .read(userRoleNotifierProvider.notifier)
                        .setRole("CUSTOMER");
                    AppRoutes.instance.go(
                      AppRoutesKey.instance.appNavigationScreen,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.instance.containerBackground
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: AppColors.instance.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.instance.primary,
                            size: 22,
                          ),
                        ),
                        const Gap(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "Continue as Guest",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.instance.textColor,
                              ),
                              const Gap(height: 2),
                              AppText(
                                text: "Browse and discover services freely",
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.instance.gray500,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: AppColors.instance.gray400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(height: 16),

              // Stylish Divider with "OR"
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.instance.containerBackground
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppText(
                        text: "OR",
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.instance.gray500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const Gap(height: 16),

              // Option 2: Log In / Sign Up Primary Card
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    AppRoutes.instance.go(
                      AppRoutesKey.instance.signInScreen,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.instance.primary,
                          const Color(0xFF8A1433),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.instance.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.login_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const Gap(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              AppText(
                                text: "Log In / Sign Up",
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              Gap(height: 2),
                              AppText(
                                text: "Access account & manage bookings",
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFF3D5DC),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
