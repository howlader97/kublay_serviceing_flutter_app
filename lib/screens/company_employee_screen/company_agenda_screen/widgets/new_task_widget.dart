import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_asserts_icons_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/chat_model.dart';
import 'package:belwork/models/technician_job_response.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/company_employee_screen/company_agenda_screen/widgets/agenda_button.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/detail_row.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class NewTaskWidget extends ConsumerWidget {
  final List<TechnicianJobItem> jobs;

  const NewTaskWidget({super.key, this.jobs = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: AppText(
            text: "No tasks found",
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
        final formattedDate =
            job.wishRepairDate != null && job.wishRepairDate!.length >= 10
            ? job.wishRepairDate!.substring(0, 10)
            : (job.wishRepairDate ?? '');
        final shortId = job.id != null && job.id!.length >= 6
            ? job.id!.substring(0, 6)
            : (job.id ?? '');

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.instance.black50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AgendaButton(
                        title: job.urgency ?? 'High urgency',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.instance.red3c,
                        borderColor: AppColors.instance.red3c,
                      ),
                      GestureDetector(
                        onTap: () {
                          final targetUserId = job.userId ?? '';
                          if (targetUserId.isNotEmpty) {
                            AppRoutes.instance.pushNamed(
                              AppRoutesKey.instance.chatScreen,
                              extra: ChatUserModel(
                                id: targetUserId,
                                name: job.user?.name ?? 'Customer',
                                avatar: job.user?.avatar ?? '',
                                jobId: job.id,
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.instance.primary,
                            border: Border.all(
                              color: AppColors.instance.primary,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              AppAssertsIconsPath.instance.chatIcon,
                              scale: 4,
                              color: AppColors.instance.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(height: 8),
                AppText(
                  text: job.title ?? " ",
                  fontWeight: FontWeight.w600,
                  color: AppColors.instance.textColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(height: 5),
                DetailRow(
                  label: "Dateline: ",
                  value: formattedDate.isNotEmpty ? formattedDate : "",
                ),
                DetailRow(
                  label: "Task ID:",
                  value: shortId.isNotEmpty ? "#$shortId" : "#",
                ),
                DetailRow(label: "Location:", value: job.address ?? ""),
                DetailRow(
                  label: "ManagerNotes:",
                  value: job.managerNotes ?? "",
                ),
                AppText(
                  text: job.description ?? "",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.instance.textColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(height: 10),
                AppButton(height: 40, title: job.status ?? "Pending Task"),
              ],
            ),
          ),
        );
      },
    );
  }
}
