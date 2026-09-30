import 'package:flutter/material.dart';

class TimelineStepModel {
  final String title;
  final bool isCompleted;

  const TimelineStepModel({
    required this.title,
    required this.isCompleted,
  });
}

class TaskModel {
  final String activeLabel;
  final String taskTitle;
  final String contractorName;
  final double price;
  final String status;
  final List<TimelineStepModel> steps;
  final String? buttonTitle;
  final VoidCallback? onTap;

  static const List<String> defaultTitles = [
    "Quotation Approved & Signed",
    "Deposit Paid to Mobile Escrow",
    "Task done",
    "Customer Release Validation",
  ];

  const TaskModel({
    this.activeLabel = "Active assignment",
    required this.taskTitle,
    required this.contractorName,
    required this.price,
    required this.status,
    required this.steps,
    this.buttonTitle = "End Task & Submit The Evidence",
    this.onTap,
  });

  /// Factory helper for creating standard 4 steps with completion statuses
  factory TaskModel.withStandardSteps({
    String activeLabel = "Active assignment",
    required String taskTitle,
    required String contractorName,
    required double price,
    required String status,
    List<bool>? stepStatuses, // e.g. [true, true, false, false]
    int completedStepCount = 0, // e.g. 2 means first 2 are true, remaining false
    String? buttonTitle = "End Task & Submit The Evidence",
    VoidCallback? onTap,
  }) {
    List<TimelineStepModel> generatedSteps = [];

    for (int i = 0; i < defaultTitles.length; i++) {
      bool isComp = stepStatuses != null
          ? (i < stepStatuses.length ? stepStatuses[i] : false)
          : (i < completedStepCount);

      generatedSteps.add(
        TimelineStepModel(
          title: defaultTitles[i],
          isCompleted: isComp,
        ),
      );
    }

    return TaskModel(
      activeLabel: activeLabel,
      taskTitle: taskTitle,
      contractorName: contractorName,
      price: price,
      status: status,
      steps: generatedSteps,
      buttonTitle: buttonTitle,
      onTap: onTap,
    );
  }
}
