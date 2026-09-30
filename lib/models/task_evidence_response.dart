class TaskEvidenceResponse {
  final String? message;
  final TaskEvidenceData? data;

  TaskEvidenceResponse({
    this.message,
    this.data,
  });

  factory TaskEvidenceResponse.fromJson(Map<String, dynamic> json) {
    return TaskEvidenceResponse(
      message: json['message']?.toString(),
      data: json['data'] != null
          ? TaskEvidenceData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class TaskEvidenceData {
  final List<TaskEvidenceItem>? allTask;
  final TaskEvidencePagination? pagination;

  TaskEvidenceData({
    this.allTask,
    this.pagination,
  });

  factory TaskEvidenceData.fromJson(Map<String, dynamic> json) {
    return TaskEvidenceData(
      allTask: (json['allTask'] as List?)
          ?.map((e) => TaskEvidenceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] != null
          ? TaskEvidencePagination.fromJson(
              json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allTask': allTask?.map((e) => e.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class TaskEvidenceItem {
  final String? id;
  final String? jobId;
  final String? summary;
  final String? note;
  final List<String>? images;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TaskEvidenceJob? job;

  TaskEvidenceItem({
    this.id,
    this.jobId,
    this.summary,
    this.note,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.job,
  });

  factory TaskEvidenceItem.fromJson(Map<String, dynamic> json) {
    return TaskEvidenceItem(
      id: json['id']?.toString(),
      jobId: json['jobId']?.toString(),
      summary: json['summary']?.toString(),
      note: json['note']?.toString(),
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      job: json['job'] != null
          ? TaskEvidenceJob.fromJson(json['job'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'summary': summary,
      'note': note,
      'images': images,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'job': job?.toJson(),
    };
  }
}

class TaskEvidenceJob {
  final String? id;
  final String? userId;
  final String? professionalId;
  final String? categoryId;
  final String? title;
  final String? description;
  final String? constructionYears;
  final String? region;
  final String? homeAsset;
  final String? status;
  final String? recurrenceType;
  final String? urgency;
  final String? wishRepairDate;
  final String? budgetFee;
  final List<String>? images;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskEvidenceJob({
    this.id,
    this.userId,
    this.professionalId,
    this.categoryId,
    this.title,
    this.description,
    this.constructionYears,
    this.region,
    this.homeAsset,
    this.status,
    this.recurrenceType,
    this.urgency,
    this.wishRepairDate,
    this.budgetFee,
    this.images,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskEvidenceJob.fromJson(Map<String, dynamic> json) {
    return TaskEvidenceJob(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      professionalId: json['professionalId']?.toString(),
      categoryId: json['categoryId']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      constructionYears: json['construction_years']?.toString() ??
          json['constructionYears']?.toString(),
      region: json['region']?.toString(),
      homeAsset: json['home_asset']?.toString() ?? json['homeAsset']?.toString(),
      status: json['status']?.toString(),
      recurrenceType: json['recurrenceType']?.toString(),
      urgency: json['urgency']?.toString(),
      wishRepairDate: json['wishRepairDate']?.toString(),
      budgetFee: json['budgetFee']?.toString(),
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
      address: json['address']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'professionalId': professionalId,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'construction_years': constructionYears,
      'region': region,
      'home_asset': homeAsset,
      'status': status,
      'recurrenceType': recurrenceType,
      'urgency': urgency,
      'wishRepairDate': wishRepairDate,
      'budgetFee': budgetFee,
      'images': images,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class TaskEvidencePagination {
  final int? page;
  final int? limit;
  final int? totalPage;
  final int? totalItems;
  final String? baseUrl;

  TaskEvidencePagination({
    this.page,
    this.limit,
    this.totalPage,
    this.totalItems,
    this.baseUrl,
  });

  factory TaskEvidencePagination.fromJson(Map<String, dynamic> json) {
    return TaskEvidencePagination(
      page: json['page'] is int
          ? json['page'] as int
          : int.tryParse(json['page']?.toString() ?? ''),
      limit: json['limit'] is int
          ? json['limit'] as int
          : int.tryParse(json['limit']?.toString() ?? ''),
      totalPage: json['totalPage'] is int
          ? json['totalPage'] as int
          : int.tryParse(json['totalPage']?.toString() ?? ''),
      totalItems: json['totalItems'] is int
          ? json['totalItems'] as int
          : int.tryParse(json['totalItems']?.toString() ?? ''),
      baseUrl: json['baseURL']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'totalPage': totalPage,
      'totalItems': totalItems,
      'baseURL': baseUrl,
    };
  }
}
