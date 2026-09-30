import 'package:flutter/material.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/texts/app_text.dart';

import '../../../../constant/app_colors.dart';
import '../../../../widgets/app_image/app_image.dart';

class RollCustomContainer extends StatelessWidget {
  final String icon;
  final String test;
  final VoidCallback onTap;
  final bool isSelected;

  const RollCustomContainer({super.key, required this.icon, required this.test, required this.onTap, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 186,
        decoration: BoxDecoration(color: AppColors.instance.containerBackground, borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              AppImage(path: icon, width: double.infinity),
              Row(
                children: [
                  AppText(text: test, fontWeight: FontWeight.w600),
                  Gap(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.instance.green59),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: isSelected ? Icon(Icons.check_circle, color: AppColors.instance.green59, size: 18) : SizedBox(height: 18, width: 18),
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
