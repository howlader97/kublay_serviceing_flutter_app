import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image_circular.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class ProfileCardWidget extends StatelessWidget {
  final String image;
  final String title;
  final String subTitle;
  const ProfileCardWidget({super.key, required this.image, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColors.instance.containerBackground),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            AppImageCircular(height: 66, width: 66, url: image),
            Gap(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(text: title, fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),
                Gap(height: 2),
                AppText(text: subTitle, color: AppColors.instance.gray4B),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
