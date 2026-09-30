import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/technician_job_response.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/company_employee_screen/company_agenda_screen/widgets/timeline_step_item.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class InProgressWidget extends StatelessWidget {
  final List<TechnicianJobItem> jobs;

  const InProgressWidget({super.key, this.jobs = const []});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: AppText(
            text: "No in-progress tasks found",
            fontSize: 16,
            color: AppColors.instance.gray4B,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.instance.containerBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: "Active assignment",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.instance.primary,
              ),
              const Gap(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: job.title ?? "Slate roof repair",
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.instance.textColor,
                        ),
                        const Gap(height: 4),
                        AppText(
                          text: "Contractor: ${job.user?.name ?? 'De Smet Roofing & Co'}",
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.instance.gray4B,
                        ),
                        if (job.managerNotes != null && job.managerNotes!.isNotEmpty) ...[
                          const Gap(height: 4),
                          AppText(
                            text: "Manager Notes: ${job.managerNotes}",
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.instance.gray4B,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText(
                        text: "€${job.budgetFee ?? '1,450'}",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.instance.textColor,
                      ),
                      const Gap(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.instance.yellow, width: 1),
                        ),
                        child: AppText(
                          text: job.status ?? "IN_PROGRESS",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.instance.textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(height: 16),
              const TimelineStepItem(title: "Quotation Approved & Signed", isCompleted: true, isLast: false),
              const TimelineStepItem(title: "Deposit Paid to Mobile Escrow", isCompleted: true, isLast: false),
              const TimelineStepItem(title: "Task done", isCompleted: false, isLast: false),
              const TimelineStepItem(title: "Customer Release Validation", isCompleted: false, isLast: true),
              const Gap(height: 16),
              AppButton(
                onTap: () {
                  AppRoutes.instance.pushNamed(
                    AppRoutesKey.instance.companySubmitEvidenceScreen,
                    extra: job.id,
                  );
                },
                title: "End Task & Submit The Evidence",
                backgroundColor: AppColors.instance.primary,
                titleColor: AppColors.instance.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                borderRadius: BorderRadius.circular(10),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
