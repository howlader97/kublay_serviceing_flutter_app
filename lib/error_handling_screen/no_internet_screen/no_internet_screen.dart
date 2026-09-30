import 'package:flutter/material.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/utils/app_size.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppSize.width(value: 5),
          children: [
            AppImage(path: "assets/images/no_internet.webp", width: AppSize.size.width * 0.4),
            Gap(height: 5),
            AppText(text: "Ooops!", fontSize: AppSize.width(value: 25), fontWeight: FontWeight.bold),

            Gap(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.size.width * 0.2),
              child: AppText(text: "No Internet Connection found Check your connection", textAlign: TextAlign.center, height: 1.5),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: AppSize.width(value: 40)),
          child: AppButton(
            onTap: () {
              AppRoutes.instance.go(AppRoutesKey.instance.initial);
            },
            height: AppSize.width(value: 50),
            margin: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
            title: "Try Again",
          ),
        ),
      ),
    );
  }
}
