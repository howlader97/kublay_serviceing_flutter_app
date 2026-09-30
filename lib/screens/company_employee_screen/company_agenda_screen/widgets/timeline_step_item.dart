import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class TimelineStepItem extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final bool isLast;

  const TimelineStepItem({super.key, required this.title, required this.isCompleted, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            isCompleted
                ? Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(color: Color(0xFF34C759), shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  )
                : Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF34C759), width: 1.5),
                      color: Colors.transparent,
                    ),
                  ),
            if (!isLast) Container(width: 1.5, height: 22, color: const Color(0xFF34C759)),
          ],
        ),
        const Gap(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: AppText(
              text: title,
              fontSize: 15,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.instance.textColor,
            ),
          ),
        ),
      ],
    );
  }
}
