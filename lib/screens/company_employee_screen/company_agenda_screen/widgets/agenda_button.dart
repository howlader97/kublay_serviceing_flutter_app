import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class AgendaButton extends StatelessWidget {
  final String title;
  final double fontSize;
  final double height;
  final FontWeight fontWeight;
  final Color? color;
  final Color? borderColor;
  const AgendaButton({super.key, required this.title, this.fontSize = 10, this.color, this.borderColor, required this.fontWeight, this.height = 31});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor ?? AppColors.instance.primary),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppText(text: title, fontSize: fontSize, fontWeight: fontWeight, color: color ?? AppColors.instance.primary),
      ),
    );
  }
}
