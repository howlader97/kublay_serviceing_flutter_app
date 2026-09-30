class YearlyInspectionResponse {
  final String? message;
  final List<YearlyInspectionItem>? data;

  YearlyInspectionResponse({
    this.message,
    this.data,
  });

  factory YearlyInspectionResponse.fromJson(Map<String, dynamic> json) {
    List<YearlyInspectionItem>? items;

    if (json['data'] != null) {
      if (json['data'] is Map<String, dynamic> &&
          json['data']['Jobs'] != null &&
          json['data']['Jobs'] is List) {
        items = (json['data']['Jobs'] as List)
            .map((item) =>
                YearlyInspectionItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (json['data'] is List) {
        items = (json['data'] as List)
            .map((item) =>
                YearlyInspectionItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    return YearlyInspectionResponse(
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

class YearlyInspectionItem {
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
  final String? address;
  final String? latitude;
  final String? longitude;
  final List<String>? images;
  final String? createdAt;
  final String? updatedAt;

  YearlyInspectionItem({
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
    this.address,
    this.latitude,
    this.longitude,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  factory YearlyInspectionItem.fromJson(Map<String, dynamic> json) {
    List<String>? parsedImages;
    if (json['images'] != null && json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((img) => img.toString())
          .where((img) => img.isNotEmpty)
          .toList();
    }

    return YearlyInspectionItem(
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
      address: json['address']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      images: parsedImages,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
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
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}