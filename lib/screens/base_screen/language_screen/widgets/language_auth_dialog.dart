import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/auth/role_setting_screen/provider/roll_settings_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class LanguageAuthDialog extends ConsumerWidget {
  const LanguageAuthDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.instance.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar with Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                // Center Icon badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.instance.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.explore_rounded,
                    size: 30,
                    color: AppColors.instance.primary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    AppRoutes.instance.pop();
                  },
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.instance.textColor14,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(height: 14),
            AppText(
              text: "Get Started",
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.instance.textColor,
            ),
            const Gap(height: 6),
            AppText(
              text: "Choose how you would like to proceed with your journey.",
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.instance.gray4B,
              textAlign: TextAlign.center,
            ),
            const Gap(height: 22),

            // Option 1: Guest Card
            InkWell(
              onTap: () async {
                await ref
                    .read(userRoleNotifierProvider.notifier)
                    .setRole("CUSTOMER");
                AppRoutes.instance.go(
                  AppRoutesKey.instance.appNavigationScreen,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.instance.containerBackground.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.instance.primary.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.instance.primary.withValues(
                          alpha: 0.12,
                        ),
                        shape: BoxShape.circle,
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
                            text: "As a Guest",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.instance.textColor14,
                          ),
                          const Gap(height: 2),
                          AppText(
                            text: "Explore services without account",
                            fontSize: 12,
                            color: AppColors.instance.gray4B,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.instance.primary,
                    ),
                  ],
                ),
              ),
            ),

            const Gap(height: 14),

            // Divider with OR
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.grey.withValues(alpha: 0.25),
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
                      color: Colors.grey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText(
                      text: "or",
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.instance.gray500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey.withValues(alpha: 0.25),
                    thickness: 1,
                  ),
                ),
              ],
            ),

            const Gap(height: 14),

            // Option 2: Log In Card
            InkWell(
              onTap: () {
                AppRoutes.instance.go(
                  AppRoutesKey.instance.signInScreen,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.instance.primary,
                      AppColors.instance.primary.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.instance.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
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
                        children: [
                          const AppText(
                            text: "Log In",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          const Gap(height: 2),
                          AppText(
                            text: "Sign in to your existing account",
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const Gap(height: 6),
          ],
        ),
      ),
    );
  }
}
