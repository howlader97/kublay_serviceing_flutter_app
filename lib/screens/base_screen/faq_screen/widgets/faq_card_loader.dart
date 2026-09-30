import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/app_size.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class FaqCardLoader extends StatelessWidget {
  const FaqCardLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSize.size.width * 0.05),
      padding: EdgeInsets.symmetric(horizontal: AppSize.size.width * 0.05, vertical: AppSize.size.width * 0.05),
      decoration: BoxDecoration(
        color: AppColors.instance.transparent,
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(AppSize.size.width * 0.02),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: "item.title item.title item.title",
              color: AppColors.instance.dark400,
              fontWeight: FontWeight.w600,
              fontSize: AppSize.size.width * 0.02,
              textAlign: TextAlign.start,
              height: 1.5,
            ),
          ),
          Gap(width: 20),
          AnimatedRotation(
            duration: Durations.medium4,
            turns: 0.25,
            child: Icon(Icons.arrow_forward_ios, color: AppColors.instance.dark400, weight: 500),
          ),
        ],
      ),
    );
  }
}
