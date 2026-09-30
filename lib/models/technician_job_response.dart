class TechnicianJobResponse {
  final String? message;
  final List<TechnicianJobItem>? data;
  final PaginationData? pagination;

  TechnicianJobResponse({
    this.message,
    this.data,
    this.pagination,
  });

  factory TechnicianJobResponse.fromJson(Map<String, dynamic> json) {
    List<TechnicianJobItem>? items;
    PaginationData? pagination;

    if (json['data'] != null) {
      if (json['data'] is Map<String, dynamic>) {
        final dataMap = json['data'] as Map<String, dynamic>;

        if (dataMap['AllJobs'] != null && dataMap['AllJobs'] is List) {
          items = (dataMap['AllJobs'] as List)
              .map((item) =>
                  TechnicianJobItem.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (dataMap['allJobs'] != null && dataMap['allJobs'] is List) {
          items = (dataMap['allJobs'] as List)
              .map((item) =>
                  TechnicianJobItem.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (dataMap['addLinks'] != null && dataMap['addLinks'] is List) {
          items = (dataMap['addLinks'] as List)
              .map((item) =>
                  TechnicianJobItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        final paginationJson = dataMap['Pagination'] ?? dataMap['pagination'];
        if (paginationJson != null && paginationJson is Map<String, dynamic>) {
          pagination = PaginationData.fromJson(paginationJson);
        }
      } else if (json['data'] is List) {
        items = (json['data'] as List)
            .map((item) =>
                TechnicianJobItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    return TechnicianJobResponse(
      message: json['message']?.toString(),
      data: items,
      pagination: pagination,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class PaginationData {
  final int? page;
  final int? limit;
  final int? totalPage;
  final int? totalItems;
  final String? baseURL;

  PaginationData({
    this.page,
    this.limit,
    this.totalPage,
    this.totalItems,
    this.baseURL,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      page: json['page'] is num
          ? (json['page'] as num).toInt()
          : int.tryParse(json['page']?.toString() ?? ''),
      limit: json['limit'] is num
          ? (json['limit'] as num).toInt()
          : int.tryParse(json['limit']?.toString() ?? ''),
      totalPage: json['totalPage'] is num
          ? (json['totalPage'] as num).toInt()
          : int.tryParse(json['totalPage']?.toString() ?? ''),
      totalItems: json['totalItems'] is num
          ? (json['totalItems'] as num).toInt()
          : int.tryParse(json['totalItems']?.toString() ?? ''),
      baseURL: json['baseURL']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'totalPage': totalPage,
      'totalItems': totalItems,
      'baseURL': baseURL,
    };
  }
}

class TechnicianJobUser {
  final String? name;
  final String? email;
  final String? contact;
  final String? avatar;

  TechnicianJobUser({
    this.name,
    this.email,
    this.contact,
    this.avatar,
  });

  factory TechnicianJobUser.fromJson(Map<String, dynamic> json) {
    return TechnicianJobUser(
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      contact: json['contact']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'contact': contact,
      'avatar': avatar,
    };
  }
}

class TechnicianJobProfessional {
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
  final String? createdAt;
  final String? updatedAt;

  TechnicianJobProfessional({
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
  });

  factory TechnicianJobProfessional.fromJson(Map<String, dynamic> json) {
    return TechnicianJobProfessional(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      corporateVatNumber: json['corporateVatNumber']?.toString(),
      cbeSecurityFile: json['cbeSecurityFile']?.toString(),
      workingRadiusKmLatitude: json['workingRadiusKmLatitude']?.toString(),
      workingRadiusKmLongitude: json['workingRadiusKmLongitude']?.toString(),
      status: json['status']?.toString(),
      type: json['type']?.toString(),
      isSupplier: json['isSupplier'] is bool ? json['isSupplier'] as bool : null,
      hourlyRate: json['hourly_rate']?.toString() ?? json['hourlyRate']?.toString(),
      category: json['category']?.toString(),
      workingTimeStart: json['working_time_start']?.toString() ?? json['workingTimeStart']?.toString(),
      workingTimeEnd: json['working_time_end']?.toString() ?? json['workingTimeEnd']?.toString(),
      availability: json['availability']?.toString(),
      websiteLink: json['websiteLink']?.toString(),
      verified: json['verified'] is bool ? json['verified'] as bool : null,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class TechnicianJobLinks {
  final String? self;
  final String? customer;
  final String? professional;

  TechnicianJobLinks({
    this.self,
    this.customer,
    this.professional,
  });

  factory TechnicianJobLinks.fromJson(Map<String, dynamic> json) {
    return TechnicianJobLinks(
      self: json['self']?.toString(),
      customer: json['customer']?.toString(),
      professional: json['professional']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'self': self,
      'customer': customer,
      'professional': professional,
    };
  }
}

class TechnicianJobItem {
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
  final String? stripeChargeId;
  final String? budgetFee;
  final String? address;
  final String? latitude;
  final String? longitude;
  final List<String>? images;
  final String? createdAt;
  final String? updatedAt;
  final TechnicianJobUser? user;
  final TechnicianJobProfessional? professional;
  final TechnicianJobLinks? links;
  final String? managerNotes;

  TechnicianJobItem({
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
    this.stripeChargeId,
    this.budgetFee,
    this.address,
    this.latitude,
    this.longitude,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.professional,
    this.links,
    this.managerNotes,
  });

  factory TechnicianJobItem.fromJson(Map<String, dynamic> json) {
    List<String>? parsedImages;
    if (json['images'] != null && json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((img) => img.toString())
          .where((img) => img.isNotEmpty)
          .toList();
    }

    TechnicianJobUser? parsedUser;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      parsedUser = TechnicianJobUser.fromJson(json['user'] as Map<String, dynamic>);
    }

    TechnicianJobProfessional? parsedProfessional;
    if (json['professional'] != null && json['professional'] is Map<String, dynamic>) {
      parsedProfessional = TechnicianJobProfessional.fromJson(json['professional'] as Map<String, dynamic>);
    }

    TechnicianJobLinks? parsedLinks;
    if (json['links'] != null && json['links'] is Map<String, dynamic>) {
      parsedLinks = TechnicianJobLinks.fromJson(json['links'] as Map<String, dynamic>);
    }

    return TechnicianJobItem(
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
      stripeChargeId: json['stripeChargeId']?.toString(),
      budgetFee: json['budgetFee']?.toString(),
      address: json['address']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      images: parsedImages,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      user: parsedUser,
      professional: parsedProfessional,
      links: parsedLinks,
      managerNotes: json['managerNotes']?.toString(),
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
      'stripeChargeId': stripeChargeId,
      'budgetFee': budgetFee,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'user': user?.toJson(),
      'professional': professional?.toJson(),
      'links': links?.toJson(),
      'managerNotes': managerNotes,
    };
  }
}
