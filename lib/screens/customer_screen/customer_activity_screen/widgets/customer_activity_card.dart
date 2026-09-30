import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';

import 'customer_timeline_step_item.dart';

class CustomerActivityCard extends StatelessWidget {
  final String activeLabel;
  final String taskTitle;
  final String contractorName;
  final double price;
  final String status;
  final List<bool>? stepStatuses;
  final String? primaryButtonTitle;
  final String? secondaryButtonTitle;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  static const List<String> standardCustomerSteps = [
    "Quotation Approved & Signed",
    "Deposit Paid to Mobile Escrow",
    "Task done",
    "Evidence",
    "Customer Release Validation",
  ];

  const CustomerActivityCard({
    super.key,
    this.activeLabel = "Active assignment",
    required this.taskTitle,
    required this.contractorName,
    required this.price,
    required this.status,
    this.stepStatuses,
    this.primaryButtonTitle,
    this.secondaryButtonTitle,
    this.onPrimaryTap,
    this.onSecondaryTap,
  });

  String _formatPrice(double val) {
    final intVal = val.toInt();
    if (val == intVal.toDouble()) {
      final str = intVal.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) {
          buffer.write(',');
        }
        buffer.write(str[i]);
      }
      return '€$buffer';
    }
    return '€${val.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStatuses = stepStatuses ?? [true, true, false, false, false];
    final isPending = status.toLowerCase() == 'pending';
    final isOnProcess = status.toLowerCase().contains("process") || status.toLowerCase().contains("progress");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.instance.containerBackground, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(text: activeLabel, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.instance.primary),
          const Gap(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(text: taskTitle, fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),
                    const Gap(height: 4),
                    AppText(text: contractorName, fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.instance.textColor),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(text: _formatPrice(price), fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),
                  const Gap(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending
                          ? const Color(0xFFFEF7E0)
                          : (isOnProcess ? const Color(0xFFFFF9E6) : const Color(0xFFEAF8ED)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isPending
                              ? const Color(0xFFB06000)
                              : (isOnProcess ? AppColors.instance.yellow : const Color(0xFF34C759)),
                          width: 1),
                    ),
                    child: AppText(
                      text: status,
                      fontSize: 12,
                      fontWeight: (isOnProcess || isPending) ? FontWeight.w400 : FontWeight.w500,
                      color: isPending
                          ? const Color(0xFFB06000)
                          : (isOnProcess ? AppColors.instance.textColor : const Color(0xFF34C759)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(height: 16),

          ...List.generate(standardCustomerSteps.length, (index) {
            final title = standardCustomerSteps[index];
            final isCompleted = index < effectiveStatuses.length ? effectiveStatuses[index] : false;
            final isLast = index == standardCustomerSteps.length - 1;

            return CustomerTimelineStepItem(title: title, isCompleted: isCompleted, isLast: isLast);
          }),

          if (primaryButtonTitle != null && primaryButtonTitle!.isNotEmpty) ...[
            const Gap(height: 16),
            AppButton(
              onTap: onPrimaryTap,
              title: primaryButtonTitle!,
              backgroundColor: AppColors.instance.primary,
              titleColor: AppColors.instance.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              borderRadius: BorderRadius.circular(10),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ],

          if (secondaryButtonTitle != null && secondaryButtonTitle!.isNotEmpty) ...[
            const Gap(height: 10),
            AppButton(
              onTap: onSecondaryTap,
              title: secondaryButtonTitle!,
              backgroundColor: const Color(0xFFF9F3F5),
              borderColor: AppColors.instance.primary,
              titleColor: AppColors.instance.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              borderRadius: BorderRadius.circular(10),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ],
        ],
      ),
    );
  }
}
