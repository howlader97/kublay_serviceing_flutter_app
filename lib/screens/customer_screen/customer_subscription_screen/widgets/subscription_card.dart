import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final Color color;
  final VoidCallback onTap;
  final bool isSelected;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.color,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2), // Border thickness
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFF2CDD79), Color(0xFFFFA500), Color(0xFF2C38DD), Color(0xFF2CDD79)],
                )
              : null,
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                AppText(text: title, fontSize: 16, fontWeight: FontWeight.w600),
                Gap(height: 20),
                AppText(text: price, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.instance.primary),
                Gap(height: 20),
                AppText(text: subtitle, fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.instance.gray4B),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
