import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/app_size.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class GoogleButton extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback onTap;
  final bool isLoading;

  const GoogleButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: AppSize.height(value: 40),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.instance.textColor),
          borderRadius: BorderRadius.circular(26),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.instance.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImage(path: icon, height: 25),
                  const Gap(width: 10),
                  AppText(text: text, fontSize: 17, fontWeight: FontWeight.w400),
                ],
              ),
      ),
    );
  }
}
