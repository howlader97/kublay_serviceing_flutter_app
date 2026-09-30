import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';

import '../../../company_employee_screen/company_agenda_screen/widgets/timeline_step_item.dart';
import '../models/task_model.dart';

class TaskContainer extends StatelessWidget {
  final String activeLabel;
  final String taskTitle;
  final String contractorName;
  final double price;
  final String status;
  final List<TimelineStepModel>? steps;
  final List<bool>? stepStatuses; // e.g. [true, true, false, false]
  final int completedStepCount; // e.g. 2 -> first 2 true, remaining 2 false
  final String? buttonTitle;
  final VoidCallback onTap;

  static const List<String> standardStepTitles = [
    "Quotation Approved & Signed",
    "Deposit Paid to Mobile Escrow",
    "Task done",
    "Customer Release Validation",
  ];

  const TaskContainer({
    super.key,
    this.activeLabel = "Active assignment",
    required this.taskTitle,
    required this.contractorName,
    required this.price,
    required this.status,
    this.steps,
    this.stepStatuses,
    this.completedStepCount = 0,
    this.buttonTitle = "End Task & Submit The Evidence",
    required this.onTap,
  });

  factory TaskContainer.fromJobItem({
    required dynamic item,
    required VoidCallback onTap,
  }) {
    final title = item.title ?? 'No Title';
    final userAddress =
        item.address ?? item.user?.name ?? 'Location unavailable';
    final rawPrice = double.tryParse(item.budgetFee ?? '0') ?? 0.0;
    final statusUpper = (item.status ?? 'PENDING').toUpperCase();
    final isFinished = statusUpper == 'FINISHED' || statusUpper == 'COMPLETED';
    final isPending = statusUpper == 'PENDING';

    String activeLabel = "Active assignment";
    List<bool> stepStatuses = [true, true, false, false];
    String buttonTitle = "End Task & Submit The Evidence";

    if (isFinished) {
      activeLabel = "Completed assignment";
      stepStatuses = [true, true, true, true];
      buttonTitle = "View Completed Receipt";
    } else if (isPending) {
      activeLabel = "Pending assignment";
      stepStatuses = [true, false, false, false];
      buttonTitle = "Submit Progress Update";
    }

    return TaskContainer(
      activeLabel: activeLabel,
      taskTitle: title,
      contractorName: "Address: $userAddress",
      price: rawPrice,
      status: item.status ?? 'PENDING',
      stepStatuses: stepStatuses,
      buttonTitle: buttonTitle,
      onTap: onTap,
    );
  }

  List<TimelineStepModel> get _effectiveSteps {
    if (steps != null && steps!.isNotEmpty) {
      return steps!;
    }

    // Build the standard 4 steps
    return List.generate(standardStepTitles.length, (index) {
      bool isCompleted = false;
      if (stepStatuses != null && index < stepStatuses!.length) {
        isCompleted = stepStatuses![index];
      } else {
        isCompleted = index < completedStepCount;
      }

      return TimelineStepModel(title: standardStepTitles[index], isCompleted: isCompleted);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeSteps = _effectiveSteps;

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
                    AppText(text: contractorName, fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.instance.gray4B),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(text: price.toStringAsFixed(2), fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),
                  const Gap(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.instance.yellow, width: 1),
                    ),
                    child: AppText(text: status, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.instance.textColor),
                  ),
                ],
              ),
            ],
          ),
          const Gap(height: 16),

          ...activeSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == activeSteps.length - 1;

            return TimelineStepItem(title: step.title, isCompleted: step.isCompleted, isLast: isLast);
          }),

          if (buttonTitle != null && buttonTitle!.isNotEmpty) ...[
            const Gap(height: 16),
            AppButton(
              onTap: onTap,
              title: buttonTitle!,
              backgroundColor: AppColors.instance.primary,
              titleColor: AppColors.instance.white,
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
