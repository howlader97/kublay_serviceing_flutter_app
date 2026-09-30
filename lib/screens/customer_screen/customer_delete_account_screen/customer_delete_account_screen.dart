import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerDeleteAccountScreen extends StatelessWidget {
  const CustomerDeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
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
              Gap(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: AppText(
                  text: "Deleting your account will permanently remove all public and private information associated with your profile.",
                  textAlign: TextAlign.center,
                ),
              ),

              Gap(height: 30),
              AppButton(
                onTap: () {
                  AppRoutes.instance.pushNamed(AppRoutesKey.instance.customerDeleteAccountForm);
                },
                title: "Continue to Delete Account",
                height: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
