import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerProfileRow extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String subTitle;
  final Widget? trailing;

  const CustomerProfileRow({super.key, required this.onTap, required this.title, required this.subTitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(text: title, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.instance.bodyText),
                  const SizedBox(height: 2),
                  AppText(text: subTitle, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.instance.gray500),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.arrow_forward, size: 20, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}
