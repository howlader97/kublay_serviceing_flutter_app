class SubsidyResponse {
  final String? message;
  final SubsidyData? data;

  SubsidyResponse({
    this.message,
    this.data,
  });

  factory SubsidyResponse.fromJson(Map<String, dynamic> json) {
    return SubsidyResponse(
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? SubsidyData.fromJson(json['data'] as Map<String, dynamic>)
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

class SubsidyData {
  final List<SubsidyItem>? allSubsidyLists;
  final SubsidyPagination? pagination;

  SubsidyData({
    this.allSubsidyLists,
    this.pagination,
  });

  factory SubsidyData.fromJson(Map<String, dynamic> json) {
    List<SubsidyItem>? items;
    if (json['allSubsidyLists'] != null && json['allSubsidyLists'] is List) {
      items = (json['allSubsidyLists'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => SubsidyItem.fromJson(e))
          .toList();
    }
    return SubsidyData(
      allSubsidyLists: items,
      pagination: json['pagination'] != null && json['pagination'] is Map<String, dynamic>
          ? SubsidyPagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allSubsidyLists': allSubsidyLists?.map((e) => e.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class SubsidyItem {
  final String? id;
  final String? region;
  final String? title;
  final String? description;
  final String? infoUrl;
  final String? amount;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  SubsidyItem({
    this.id,
    this.region,
    this.title,
    this.description,
    this.infoUrl,
    this.amount,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory SubsidyItem.fromJson(Map<String, dynamic> json) {
    return SubsidyItem(
      id: json['id']?.toString(),
      region: json['region']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      infoUrl: json['infoUrl']?.toString(),
      amount: json['amount']?.toString(),
      isActive: json['isActive'] is bool
          ? json['isActive']
          : (json['isActive']?.toString().toLowerCase() == 'true'),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region': region,
      'title': title,
      'description': description,
      'infoUrl': infoUrl,
      'amount': amount,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class SubsidyPagination {
  final int? page;
  final int? limit;
  final int? totalPage;
  final int? totalItems;
  final String? baseURL;

  SubsidyPagination({
    this.page,
    this.limit,
    this.totalPage,
    this.totalItems,
    this.baseURL,
  });

  factory SubsidyPagination.fromJson(Map<String, dynamic> json) {
    return SubsidyPagination(
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
