import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/technician_job_response.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/technician_screen/technician_planner_screen/widgets/task_container.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class AllAssignment extends StatelessWidget {
  final List<TechnicianJobItem> jobs;

  const AllAssignment({super.key, this.jobs = const []});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: AppText(
            text: 'No assignments found for selected date.',
            fontSize: 14,
            color: AppColors.instance.gray500,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final item = jobs[index];
        return TaskContainer.fromJobItem(
          item: item,
          onTap: () {
            AppRoutes.instance.pushNamed(
              AppRoutesKey.instance.technicianSubmitEvidence,
              extra: item.id,
            );
          },
        );
      },
    );
  }
}
