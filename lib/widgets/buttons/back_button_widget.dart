import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';

class BackButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final Widget? child;
  final double width;
  final double height;

  const BackButtonWidget({super.key, required this.onTap, this.child, this.width = 40, this.height = 40});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: AppColors.instance.containerBackground, borderRadius: BorderRadius.circular(6)),
        child: child ?? Icon(Icons.arrow_back, color: AppColors.instance.textColor, size: 20),
      ),
    );
  }
}
