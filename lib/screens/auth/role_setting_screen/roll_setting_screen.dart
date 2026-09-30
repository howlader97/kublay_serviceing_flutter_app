import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_asserts_icons_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/auth/role_setting_screen/provider/roll_settings_provider.dart';
import 'package:belwork/screens/auth/role_setting_screen/widgets/customer_roll_container.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class RollSettingScreen extends ConsumerWidget {
  const RollSettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollProvider = ref.watch(rollSettingsProvider);
    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Gap(height: 10),
              Center(
                child: AppText(text: "Choose your role.", fontSize: 32, fontWeight: FontWeight.w600),
              ),
              Gap(height: 10),
              AppText(text: "Choose the role that best describes\n you to continue.", textAlign: TextAlign.center),
              Gap(height: 10),
              Row(
                children: [
                  Expanded(
                    child: RollCustomContainer(
                      icon: AppAssertsIconsPath.instance.customerIcon,
                      test: "Customer",
                      onTap: () async {
                        ref.read(rollSettingsProvider.notifier).state = 0;
                        await ref.read(userRoleNotifierProvider.notifier).setRole("CUSTOMER");
                        AppRoutes.instance.pushNamed(AppRoutesKey.instance.signUpScreen);
                      },
                      isSelected: rollProvider == 0,
                    ),
                  ),

                  Gap(width: 10),

                  Expanded(
                    child: RollCustomContainer(
                      icon: AppAssertsIconsPath.instance.technician,
                      test: 'Craftsman',
                      onTap: () async {
                        ref.read(rollSettingsProvider.notifier).state = 1;
                        await ref.read(userRoleNotifierProvider.notifier).setRole("TECHNICIAN");
                        AppRoutes.instance.pushNamed(AppRoutesKey.instance.signUpScreen);
                      },
                      isSelected: rollProvider == 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
