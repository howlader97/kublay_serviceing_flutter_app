import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          AppText(text: label, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),
          AppText(text: value, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.instance.gray500),
        ],
      ),
    );
  }
}
