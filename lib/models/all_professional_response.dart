class AllProfessionalResponse {
  final String? message;
  final AllProfessionalData? data;

  AllProfessionalResponse({
    this.message,
    this.data,
  });

  factory AllProfessionalResponse.fromJson(Map<String, dynamic> json) {
    return AllProfessionalResponse(
      message: json['message'] as String?,
      data: json['data'] != null
          ? AllProfessionalData.fromJson(json['data'])
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

class AllProfessionalData {
  final List<ProfessionalModel>? allProfessional;
  final Pagination? pagination;

  AllProfessionalData({
    this.allProfessional,
    this.pagination,
  });

  factory AllProfessionalData.fromJson(Map<String, dynamic> json) {
    return AllProfessionalData(
      allProfessional: (json['allProfessional'] as List?)
          ?.map((e) => ProfessionalModel.fromJson(e))
          .toList(),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allProfessional':
      allProfessional?.map((e) => e.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class ProfessionalModel {
  final String? id;
  final String? userId;
  final String? corporateVatNumber;
  final String? cbeSecurityFile;
  final String? workingRadiusKmLatitude;
  final String? workingRadiusKmLongitude;
  final String? status;
  final String? type;
  final bool? isSupplier;
  final String? hourlyRate;
  final String? category;
  final String? workingTimeStart;
  final String? workingTimeEnd;
  final String? availability;
  final String? websiteLink;
  final bool? verified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ProfessionalUser? user;

  ProfessionalModel({
    this.id,
    this.userId,
    this.corporateVatNumber,
    this.cbeSecurityFile,
    this.workingRadiusKmLatitude,
    this.workingRadiusKmLongitude,
    this.status,
    this.type,
    this.isSupplier,
    this.hourlyRate,
    this.category,
    this.workingTimeStart,
    this.workingTimeEnd,
    this.availability,
    this.websiteLink,
    this.verified,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      corporateVatNumber: json['corporateVatNumber'] as String?,
      cbeSecurityFile: json['cbeSecurityFile'] as String?,
      workingRadiusKmLatitude:
      json['workingRadiusKmLatitude'] as String?,
      workingRadiusKmLongitude:
      json['workingRadiusKmLongitude'] as String?,
      status: json['status'] as String?,
      type: json['type'] as String?,
      isSupplier: json['isSupplier'] as bool?,
      hourlyRate: json['hourly_rate'] as String?,
      category: json['category'] as String?,
      workingTimeStart: json['working_time_start'] as String?,
      workingTimeEnd: json['working_time_end'] as String?,
      availability: json['availability'] as String?,
      websiteLink: json['websiteLink'] as String?,
      verified: json['verified'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      user: json['user'] != null
          ? ProfessionalUser.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'corporateVatNumber': corporateVatNumber,
      'cbeSecurityFile': cbeSecurityFile,
      'workingRadiusKmLatitude': workingRadiusKmLatitude,
      'workingRadiusKmLongitude': workingRadiusKmLongitude,
      'status': status,
      'type': type,
      'isSupplier': isSupplier,
      'hourly_rate': hourlyRate,
      'category': category,
      'working_time_start': workingTimeStart,
      'working_time_end': workingTimeEnd,
      'availability': availability,
      'websiteLink': websiteLink,
      'verified': verified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}

class ProfessionalUser {
  final String? name;
  final String? email;
  final String? avatar;
  final String? contact;

  ProfessionalUser({
    this.name,
    this.email,
    this.avatar,
    this.contact,
  });

  factory ProfessionalUser.fromJson(Map<String, dynamic> json) {
    return ProfessionalUser(
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      contact: json['contact'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatar': avatar,
      'contact': contact,
    };
  }
}

class Pagination {
  final int? page;
  final int? limit;
  final int? totalPage;
  final int? totalItems;
  final String? baseUrl;

  Pagination({
    this.page,
    this.limit,
    this.totalPage,
    this.totalItems,
    this.baseUrl,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] is int
          ? json['page']
          : int.tryParse(json['page']?.toString() ?? ''),
      limit: json['limit'] is int
          ? json['limit']
          : int.tryParse(json['limit']?.toString() ?? ''),
      totalPage: json['totalPage'] is int
          ? json['totalPage']
          : int.tryParse(json['totalPage']?.toString() ?? ''),
      totalItems: json['totalItems'] is int
          ? json['totalItems']
          : int.tryParse(json['totalItems']?.toString() ?? ''),
      baseUrl: json['baseURL'] as String?,
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