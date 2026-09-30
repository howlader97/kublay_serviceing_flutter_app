class ServiceCategoryResponse {
  final String? message;
  final List<ServiceCategoryModel>? data;

  ServiceCategoryResponse({
    this.message,
    this.data,
  });

  factory ServiceCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryResponse(
      message: json['message'] as String?,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => ServiceCategoryModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class ServiceCategoryModel {
  final String? id;
  final String? name;
  final String? description;
  final String? type;
  final bool? isActive;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceCategoryModel({
    this.id,
    this.name,
    this.description,
    this.type,
    this.isActive,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String?,
      isActive: json['isActive'] as bool?,
      avatar: json['avatar'] as String?,
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
      'name': name,
      'description': description,
      'type': type,
      'isActive': isActive,
      'avatar': avatar,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
