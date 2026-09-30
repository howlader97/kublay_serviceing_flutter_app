import 'package:flutter/material.dart';
import 'package:belwork/constant/app_asserts_icons_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerDeleteAccountForm extends StatelessWidget {
  const CustomerDeleteAccountForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SingleChildScrollView(
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
                    Gap(width: 12),
                    AppText(text: "Delete account", fontWeight: FontWeight.w600, fontSize: 24, color: AppColors.instance.bodyText),
                  ],
                ),
                Gap(height: 30),
                Center(
                  child: AppText(text: "Log in to confirm", fontWeight: FontWeight.w600, fontSize: 24, color: AppColors.instance.bodyText),
                ),
                Gap(height: 10),
                Center(
                  child: AppText(
                    text: "Enter the login information for your\n account to confirm deletion.",
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: AppColors.instance.bodyText,
                    textAlign: TextAlign.center,
                  ),
                ),
                Gap(height: 20),
                AppInputWidgetTwo(
                  title: "E-mail",
                  hintText: "Enter your mail",
                  prefix: Image.asset(AppAssertsIconsPath.instance.mailPassword, scale: 3),
                ),
                AppInputWidgetTwo(
                  title: "Password",
                  hintText: "Enter your mail",
                  prefix: Image.asset(AppAssertsIconsPath.instance.lockPassword, scale: 3),
                ),

                Gap(height: 20),
                AppButton(title: "Continue to Delete Account", height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
