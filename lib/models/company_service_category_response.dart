class CompanyServiceCategoryResponse {
  final String? message;
  final List<CompanyServiceCategoryItem>? data;

  CompanyServiceCategoryResponse({this.message, this.data});

  factory CompanyServiceCategoryResponse.fromJson(dynamic json) {
    if (json is! Map) return CompanyServiceCategoryResponse();
    final map = Map<String, dynamic>.from(json);
    return CompanyServiceCategoryResponse(
      message: map["message"]?.toString(),
      data: map["data"] != null && map["data"] is List
          ? (map["data"] as List)
              .map((e) => CompanyServiceCategoryItem.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "data": data?.map((e) => e.toJson()).toList(),
    };
  }
}

class CompanyServiceCategoryItem {
  final String? id;
  final String? professionalId;
  final String? categoryId;
  final String? priorityLevel;
  final String? price;
  final String? avatar;
  final String? createdAt;
  final String? updatedAt;
  final CompanyCategoryDetails? category;

  CompanyServiceCategoryItem({
    this.id,
    this.professionalId,
    this.categoryId,
    this.priorityLevel,
    this.price,
    this.avatar,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  factory CompanyServiceCategoryItem.fromJson(dynamic json) {
    if (json is! Map) return CompanyServiceCategoryItem();
    final map = Map<String, dynamic>.from(json);
    return CompanyServiceCategoryItem(
      id: map["id"]?.toString(),
      professionalId: map["professionalId"]?.toString(),
      categoryId: map["categoryId"]?.toString(),
      priorityLevel: map["priorityLevel"]?.toString(),
      price: map["price"]?.toString(),
      avatar: map["avatar"]?.toString(),
      createdAt: map["createdAt"]?.toString(),
      updatedAt: map["updatedAt"]?.toString(),
      category: map["category"] != null && map["category"] is Map
          ? CompanyCategoryDetails.fromJson(map["category"])
          : null,
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
      "category": category?.toJson(),
    };
  }
}

class CompanyCategoryDetails {
  final String? id;
  final String? name;
  final String? description;
  final String? type;
  final bool? isActive;
  final String? avatar;
  final String? createdAt;
  final String? updatedAt;

  CompanyCategoryDetails({
    this.id,
    this.name,
    this.description,
    this.type,
    this.isActive,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyCategoryDetails.fromJson(dynamic json) {
    if (json is! Map) return CompanyCategoryDetails();
    final map = Map<String, dynamic>.from(json);
    return CompanyCategoryDetails(
      id: map["id"]?.toString(),
      name: map["name"]?.toString(),
      description: map["description"]?.toString(),
      type: map["type"]?.toString(),
      isActive: map["isActive"] as bool?,
      avatar: map["avatar"]?.toString(),
      createdAt: map["createdAt"]?.toString(),
      updatedAt: map["updatedAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "type": type,
      "isActive": isActive,
      "avatar": avatar,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}
