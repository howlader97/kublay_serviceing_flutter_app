class ProfessionalByCategoryResponse {
  final String? message;
  final ProfessionalByCategoryData? data;

  ProfessionalByCategoryResponse({
    this.message,
    this.data,
  });

  factory ProfessionalByCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ProfessionalByCategoryResponse(
      message: json['message'] as String?,
      data: json['data'] != null
          ? ProfessionalByCategoryData.fromJson(json['data'])
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

class ProfessionalByCategoryData {
  final List<ProfessionalByCategoryItem>? allProfessional;
  final ProfessionalPagination? pagination;

  ProfessionalByCategoryData({
    this.allProfessional,
    this.pagination,
  });

  factory ProfessionalByCategoryData.fromJson(Map<String, dynamic> json) {
    return ProfessionalByCategoryData(
      allProfessional: (json['allProfessional'] as List?)
          ?.map((e) => ProfessionalByCategoryItem.fromJson(e))
          .toList(),
      pagination: json['pagination'] != null
          ? ProfessionalPagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allProfessional': allProfessional?.map((e) => e.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class ProfessionalByCategoryItem {
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
  final List<String>? categories;
  final String? workingTimeStart;
  final String? workingTimeEnd;
  final String? availability;
  final String? websiteLink;
  final bool? verified;
  final String? createdAt;
  final String? updatedAt;
  final ProfessionalCategoryUser? user;

  ProfessionalByCategoryItem({
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
    this.categories,
    this.workingTimeStart,
    this.workingTimeEnd,
    this.availability,
    this.websiteLink,
    this.verified,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory ProfessionalByCategoryItem.fromJson(Map<String, dynamic> json) {
    return ProfessionalByCategoryItem(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      corporateVatNumber: json['corporateVatNumber'] as String?,
      cbeSecurityFile: json['cbeSecurityFile'] as String?,
      workingRadiusKmLatitude: json['workingRadiusKmLatitude'] as String?,
      workingRadiusKmLongitude: json['workingRadiusKmLongitude'] as String?,
      status: json['status'] as String?,
      type: json['type'] as String?,
      isSupplier: json['isSupplier'] as bool?,
      hourlyRate: json['hourly_rate']?.toString(),
      categories: (json['categories'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      workingTimeStart: json['working_time_start'] as String?,
      workingTimeEnd: json['working_time_end'] as String?,
      availability: json['availability'] as String?,
      websiteLink: json['websiteLink'] as String?,
      verified: json['verified'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      user: json['user'] != null
          ? ProfessionalCategoryUser.fromJson(json['user'])
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
      'categories': categories,
      'working_time_start': workingTimeStart,
      'working_time_end': workingTimeEnd,
      'availability': availability,
      'websiteLink': websiteLink,
      'verified': verified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'user': user?.toJson(),
    };
  }
}

class ProfessionalCategoryUser {
  final String? id;
  final String? name;
  final String? email;
  final String? avatar;
  final String? role;
  final String? contact;
  final String? address;
  final String? bio;
  final num? rating;
  final bool? emailVerified;
  final String? latitude;
  final String? longitude;

  ProfessionalCategoryUser({
    this.id,
    this.name,
    this.email,
    this.avatar,
    this.role,
    this.contact,
    this.address,
    this.bio,
    this.rating,
    this.emailVerified,
    this.latitude,
    this.longitude,
  });

  factory ProfessionalCategoryUser.fromJson(Map<String, dynamic> json) {
    return ProfessionalCategoryUser(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String?,
      contact: json['contact'] as String?,
      address: json['address'] as String?,
      bio: json['bio'] as String?,
      rating: json['rating'] is num
          ? json['rating']
          : num.tryParse(json['rating']?.toString() ?? ''),
      emailVerified: json['emailVerified'] as bool?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role,
      'contact': contact,
      'address': address,
      'bio': bio,
      'rating': rating,
      'emailVerified': emailVerified,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class ProfessionalPagination {
  final int? page;
  final int? limit;
  final int? totalPage;
  final int? totalItems;
  final String? baseUrl;

  ProfessionalPagination({
    this.page,
    this.limit,
    this.totalPage,
    this.totalItems,
    this.baseUrl,
  });

  factory ProfessionalPagination.fromJson(Map<String, dynamic> json) {
    return ProfessionalPagination(
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
