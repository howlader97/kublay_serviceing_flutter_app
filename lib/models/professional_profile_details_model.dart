class ProfessionalProfileDetailsModel {
  final String? message;
  final ProfessionalProfileDetailsData? data;

  ProfessionalProfileDetailsModel({this.message, this.data});

  factory ProfessionalProfileDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalProfileDetailsModel(
      message: json["message"]?.toString(),
      data: json["data"] != null
          ? ProfessionalProfileDetailsData.fromJson(
              json["data"] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {"message": message, "data": data?.toJson()};
  }
}

class ProfessionalProfileDetailsData {
  final ProfessionalData? professional;
  final List<ProjectData>? allProjects;
  final List<ReviewData>? allReviews;
  final List<ProfessionalServiceData>? allServices;

  ProfessionalProfileDetailsData({
    this.professional,
    this.allProjects,
    this.allReviews,
    this.allServices,
  });

  factory ProfessionalProfileDetailsData.fromJson(Map<String, dynamic> json) {
    return ProfessionalProfileDetailsData(
      professional: json["professional"] != null
          ? ProfessionalData.fromJson(
              json["professional"] as Map<String, dynamic>,
            )
          : null,
      allProjects: json["allProjects"] != null && json["allProjects"] is List
          ? (json["allProjects"] as List)
                .map((e) => ProjectData.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      allReviews: json["allReviews"] != null && json["allReviews"] is List
          ? (json["allReviews"] as List)
                .map((e) => ReviewData.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      allServices: json["allServices"] != null && json["allServices"] is List
          ? (json["allServices"] as List)
                .map(
                  (e) => ProfessionalServiceData.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "professional": professional?.toJson(),
      "allProjects": allProjects?.map((e) => e.toJson()).toList(),
      "allReviews": allReviews?.map((e) => e.toJson()).toList(),
      "allServices": allServices?.map((e) => e.toJson()).toList(),
    };
  }
}

class ProfessionalData {
  final String? id;
  final String? userId;
  final String? corporateVatNumber;
  final String? cbeSecurityFile;
  final String? workingRadiusKmLatitude;
  final String? workingRadiusKmLongitude;
  final String? workingAddress;
  final String? status;
  final String? type;
  final bool? isSupplier;
  final String? hourlyRate;
  final String? category;
  final List<dynamic>? categories;
  final String? workingTime;
  final String? workingTimeStart;
  final String? workingTimeEnd;
  final String? availability;
  final String? websiteLink;
  final bool? verified;
  final num? rating;
  final String? createdAt;
  final String? updatedAt;
  final ProfessionalUserData? user;

  ProfessionalData({
    this.id,
    this.userId,
    this.corporateVatNumber,
    this.cbeSecurityFile,
    this.workingRadiusKmLatitude,
    this.workingRadiusKmLongitude,
    this.workingAddress,
    this.status,
    this.type,
    this.isSupplier,
    this.hourlyRate,
    this.category,
    this.categories,
    this.workingTime,
    this.workingTimeStart,
    this.workingTimeEnd,
    this.availability,
    this.websiteLink,
    this.verified,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory ProfessionalData.fromJson(Map<String, dynamic> json) {
    return ProfessionalData(
      id: json["id"]?.toString(),
      userId: json["userId"]?.toString(),
      corporateVatNumber: json["corporateVatNumber"]?.toString(),
      cbeSecurityFile: json["cbeSecurityFile"]?.toString(),
      workingRadiusKmLatitude: json["workingRadiusKmLatitude"]?.toString(),
      workingRadiusKmLongitude: json["workingRadiusKmLongitude"]?.toString(),
      workingAddress:
          json["workingAddress"]?.toString() ??
          json["working_address"]?.toString() ??
          json["address"]?.toString(),
      status: json["status"]?.toString(),
      type: json["type"]?.toString(),
      isSupplier: json["isSupplier"] as bool?,
      hourlyRate: json["hourly_rate"]?.toString() ?? json["hourlyRate"]?.toString(),
      category: json["category"]?.toString(),
      categories: json["categories"] != null && json["categories"] is List
          ? json["categories"] as List
          : [],
      workingTime: json["working_time"]?.toString(),
      workingTimeStart: json["working_time_start"]?.toString(),
      workingTimeEnd: json["working_time_end"]?.toString(),
      availability: json["availability"]?.toString(),
      websiteLink: json["websiteLink"]?.toString(),
      verified: json["verified"] as bool?,
      rating: json["rating"] is num
          ? json["rating"] as num
          : num.tryParse(json["rating"]?.toString() ?? ""),
      createdAt: json["createdAt"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
      user: json["user"] != null
          ? ProfessionalUserData.fromJson(json["user"] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "corporateVatNumber": corporateVatNumber,
      "cbeSecurityFile": cbeSecurityFile,
      "workingRadiusKmLatitude": workingRadiusKmLatitude,
      "workingRadiusKmLongitude": workingRadiusKmLongitude,
      "workingAddress": workingAddress,
      "status": status,
      "type": type,
      "isSupplier": isSupplier,
      "hourly_rate": hourlyRate,
      "category": category,
      "categories": categories,
      "working_time": workingTime,
      "working_time_start": workingTimeStart,
      "working_time_end": workingTimeEnd,
      "availability": availability,
      "websiteLink": websiteLink,
      "verified": verified,
      "rating": rating,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "user": user?.toJson(),
    };
  }
}

class ProfessionalUserData {
  final String? id;
  final String? name;
  final String? contact;
  final String? avatar;
  final String? role;
  final String? takenServices;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? bio;
  final num? rating;

  ProfessionalUserData({
    this.id,
    this.name,
    this.contact,
    this.avatar,
    this.role,
    this.takenServices,
    this.latitude,
    this.longitude,
    this.address,
    this.bio,
    this.rating,
  });

  factory ProfessionalUserData.fromJson(Map<String, dynamic> json) {
    return ProfessionalUserData(
      id: json["id"]?.toString(),
      name: json["name"]?.toString(),
      contact: json["contact"]?.toString(),
      avatar: json["avatar"]?.toString(),
      role: json["role"]?.toString(),
      takenServices: json["taken_services"]?.toString(),
      latitude: double.tryParse(json["latitude"]?.toString() ?? ""),
      longitude: double.tryParse(json["longitude"]?.toString() ?? ""),
      address: json["address"]?.toString(),
      bio: json["bio"]?.toString(),
      rating: json["rating"] is num ? json["rating"] as num : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "contact": contact,
      "avatar": avatar,
      "role": role,
      "taken_services": takenServices,
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
      "bio": bio,
      "rating": rating,
    };
  }
}

class ProjectData {
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
  final List<String>? images;
  final String? address;
  final String? latitude;
  final String? longitude;
  final String? createdAt;
  final String? updatedAt;

  ProjectData({
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
    this.images,
    this.address,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory ProjectData.fromJson(Map<String, dynamic> json) {
    return ProjectData(
      id: json["id"]?.toString(),
      userId: json["userId"]?.toString(),
      professionalId: json["professionalId"]?.toString(),
      categoryId: json["categoryId"]?.toString(),
      title: json["title"]?.toString(),
      description: json["description"]?.toString(),
      constructionYears: json["construction_years"]?.toString(),
      region: json["region"]?.toString(),
      homeAsset: json["home_asset"]?.toString(),
      status: json["status"]?.toString(),
      recurrenceType: json["recurrenceType"]?.toString(),
      urgency: json["urgency"]?.toString(),
      wishRepairDate: json["wishRepairDate"]?.toString(),
      stripeChargeId: json["stripeChargeId"]?.toString(),
      budgetFee: json["budgetFee"]?.toString(),
      images: json["images"] != null && json["images"] is List
          ? (json["images"] as List).map((e) => e.toString()).toList()
          : [],
      address: json["address"]?.toString(),
      latitude: json["latitude"]?.toString(),
      longitude: json["longitude"]?.toString(),
      createdAt: json["createdAt"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "professionalId": professionalId,
      "categoryId": categoryId,
      "title": title,
      "description": description,
      "construction_years": constructionYears,
      "region": region,
      "home_asset": homeAsset,
      "status": status,
      "recurrenceType": recurrenceType,
      "urgency": urgency,
      "wishRepairDate": wishRepairDate,
      "stripeChargeId": stripeChargeId,
      "budgetFee": budgetFee,
      "images": images,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}

class ProfessionalServiceData {
  final String? id;
  final String? professionalId;
  final String? categoryId;
  final String? priorityLevel;
  final String? price;
  final String? avatar;
  final String? createdAt;
  final String? updatedAt;

  ProfessionalServiceData({
    this.id,
    this.professionalId,
    this.categoryId,
    this.priorityLevel,
    this.price,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfessionalServiceData.fromJson(Map<String, dynamic> json) {
    return ProfessionalServiceData(
      id: json["id"]?.toString(),
      professionalId: json["professionalId"]?.toString(),
      categoryId: json["categoryId"]?.toString(),
      priorityLevel: json["priorityLevel"]?.toString(),
      price: json["price"]?.toString(),
      avatar: json["avatar"]?.toString(),
      createdAt: json["createdAt"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "professionalId": professionalId,
      "categoryId": categoryId,
      "priorityLevel": priorityLevel,
      "price": price,
      "avatar": avatar,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}

class ReviewData {
  final String? id;
  final String? jobId;
  final String? userId;
  final String? professionalId;
  final num? rating;
  final String? note;
  final List<String>? images;
  final String? createdAt;
  final String? updatedAt;
  final String? userName;
  final String? userAvatar;

  ReviewData({
    this.id,
    this.jobId,
    this.userId,
    this.professionalId,
    this.rating,
    this.note,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.userAvatar,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      id: json["id"]?.toString(),
      jobId: json["jobId"]?.toString(),
      userId: json["userId"]?.toString(),
      professionalId: json["professionalId"]?.toString(),
      rating: json["rating"] is num
          ? json["rating"] as num
          : num.tryParse(json["rating"]?.toString() ?? ""),
      note: json["note"]?.toString(),
      images: json["images"] != null && json["images"] is List
          ? (json["images"] as List).map((e) => e.toString()).toList()
          : [],
      createdAt: json["createdAt"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
      userName: json["user"] != null && json["user"] is Map
          ? json["user"]["name"]?.toString()
          : json["userName"]?.toString(),
      userAvatar: json["user"] != null && json["user"] is Map
          ? json["user"]["avatar"]?.toString()
          : json["userAvatar"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "jobId": jobId,
      "userId": userId,
      "professionalId": professionalId,
      "rating": rating,
      "note": note,
      "images": images,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "userName": userName,
      "userAvatar": userAvatar,
    };
  }
}
