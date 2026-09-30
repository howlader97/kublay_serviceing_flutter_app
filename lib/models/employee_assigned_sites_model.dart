import 'package:belwork/models/technician_job_response.dart';

class EmployeeAssignedSitesResponse {
  final String? message;
  final List<EmployeeAssignedSiteItem>? data;

  EmployeeAssignedSitesResponse({
    this.message,
    this.data,
  });

  factory EmployeeAssignedSitesResponse.fromJson(Map<String, dynamic> json) {
    List<EmployeeAssignedSiteItem>? items;
    if (json['data'] != null && json['data'] is List) {
      items = (json['data'] as List)
          .map((e) => EmployeeAssignedSiteItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return EmployeeAssignedSitesResponse(
      message: json['message']?.toString(),
      data: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class EmployeeAssignedSiteItem {
  final String? id;
  final String? jobId;
  final String? companyId;
  final String? employeeId;
  final String? deadline;
  final String? status;
  final String? managerNotes;
  final String? assignedAt;
  final String? createdAt;
  final String? updatedAt;
  final TechnicianJobItem? job;

  EmployeeAssignedSiteItem({
    this.id,
    this.jobId,
    this.companyId,
    this.employeeId,
    this.deadline,
    this.status,
    this.managerNotes,
    this.assignedAt,
    this.createdAt,
    this.updatedAt,
    this.job,
  });

  factory EmployeeAssignedSiteItem.fromJson(Map<String, dynamic> json) {
    TechnicianJobItem? parsedJob;
    if (json['job'] != null && json['job'] is Map<String, dynamic>) {
      parsedJob = TechnicianJobItem.fromJson(json['job'] as Map<String, dynamic>);
    }

    return EmployeeAssignedSiteItem(
      id: json['id']?.toString(),
      jobId: json['jobId']?.toString(),
      companyId: json['companyId']?.toString(),
      employeeId: json['employeeId']?.toString(),
      deadline: json['deadline']?.toString(),
      status: json['status']?.toString(),
      managerNotes: json['managerNotes']?.toString(),
      assignedAt: json['assignedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      job: parsedJob,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'companyId': companyId,
      'employeeId': employeeId,
      'deadline': deadline,
      'status': status,
      'managerNotes': managerNotes,
      'assignedAt': assignedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'job': job?.toJson(),
    };
  }

  /// Converts this site assignment item to a TechnicianJobItem for convenience
  TechnicianJobItem get effectiveJob {
    final effectiveStatus = (job?.status != null && job!.status!.isNotEmpty)
        ? job!.status
        : status;

    if (job != null) {
      return TechnicianJobItem(
        id: job!.id ?? jobId ?? id,
        userId: job!.userId,
        professionalId: job!.professionalId,
        categoryId: job!.categoryId,
        title: job!.title,
        description: job!.description,
        constructionYears: job!.constructionYears,
        region: job!.region,
        homeAsset: job!.homeAsset,
        status: effectiveStatus,
        recurrenceType: job!.recurrenceType,
        urgency: job!.urgency,
        wishRepairDate: deadline ?? job!.wishRepairDate,
        budgetFee: job!.budgetFee,
        address: job!.address,
        latitude: job!.latitude,
        longitude: job!.longitude,
        images: job!.images,
        createdAt: job!.createdAt ?? createdAt,
        updatedAt: job!.updatedAt ?? updatedAt,
        user: job!.user,
        managerNotes: managerNotes ?? job!.managerNotes,
      );
    }
    return TechnicianJobItem(
      id: jobId ?? id,
      status: status,
      wishRepairDate: deadline,
      createdAt: createdAt,
      updatedAt: updatedAt,
      managerNotes: managerNotes,
    );
  }
}
