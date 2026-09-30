import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerGuestHeader extends StatelessWidget {
  const CustomerGuestHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: AppColors.instance.containerBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 50,
              color: AppColors.instance.textColor.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppText(
          text: "Guest User",
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.instance.textColor14,
        ),
        const SizedBox(height: 4),
        AppText(
          text: "Log in to access your full profile",
          fontSize: 13,
          color: AppColors.instance.textColor.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}
