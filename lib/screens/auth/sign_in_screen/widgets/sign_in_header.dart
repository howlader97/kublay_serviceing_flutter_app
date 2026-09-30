import 'package:belwork/constant/app_asserts_icons_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/constant/app_constant.dart';
import 'package:belwork/utils/app_size.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'package:flutter/material.dart';

class SignInHeader extends StatelessWidget {
  const SignInHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 50),
      child: Row(
        children: [
          AppImage(
            height: AppSize.height(value: 80),
            width: AppSize.width(value: 60),
            path: AppAssertsIconsPath.instance.splashIcon,
          ),
          Gap(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: "Belwork ",
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.instance.primary,
                fontFamily: AppConstant.instance.calibri,
                translate: false,
              ),
              AppText(
                text: "CONNECTING SKILLS. BUILDING TRUST.",
                color: AppColors.instance.primary,
                fontSize: 13,
                translate: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}