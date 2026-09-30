import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/technician_job_response.dart';
import 'package:belwork/screens/technician_screen/technician_planner_screen/widgets/task_container.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CompleteAssignment extends StatelessWidget {
  final List<TechnicianJobItem> jobs;

  const CompleteAssignment({super.key, this.jobs = const []});

  @override
  Widget build(BuildContext context) {
    final filtered = jobs.where((item) {
      final s = (item.status ?? '').toUpperCase();
      return s == 'FINISHED' || s == 'COMPLETED' || s == 'COMPLETE' || s.contains('COMPLETE');
    }).toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: AppText(
            text: 'No completed assignments found for selected date.',
            fontSize: 14,
            color: AppColors.instance.gray500,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return TaskContainer.fromJobItem(
          item: item,
          onTap: () {},
        );
      },
    );
  }
}
