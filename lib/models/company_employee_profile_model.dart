class CompanyEmployeeProfileResponse {
  final String? message;
  final CompanyEmployeeProfileData? data;

  CompanyEmployeeProfileResponse({
    this.message,
    this.data,
  });

  factory CompanyEmployeeProfileResponse.fromJson(Map<String, dynamic> json) {
    CompanyEmployeeProfileData? parsedData;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      parsedData = CompanyEmployeeProfileData.fromJson(
        json['data'] as Map<String, dynamic>,
      );
    }

    return CompanyEmployeeProfileResponse(
      message: json['message']?.toString(),
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class CompanyEmployeeProfileData {
  final String? id;
  final String? userId;
  final String? companyId;
  final String? salary;
  final String? employmentType;
  final String? designation;
  final String? skill;
  final bool? proposalPermission;
  final String? status;
  final String? note;
  final bool? isActive;
  final String? joinedAt;
  final bool? quotationPermission;
  final String? terminatedAt;
  final bool? verified;
  final String? createdAt;
  final String? updatedAt;
  final CompanyEmployeeUser? user;

  CompanyEmployeeProfileData({
    this.id,
    this.userId,
    this.companyId,
    this.salary,
    this.employmentType,
    this.designation,
    this.skill,
    this.proposalPermission,
    this.status,
    this.note,
    this.isActive,
    this.joinedAt,
    this.quotationPermission,
    this.terminatedAt,
    this.verified,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory CompanyEmployeeProfileData.fromJson(Map<String, dynamic> json) {
    CompanyEmployeeUser? parsedUser;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      parsedUser = CompanyEmployeeUser.fromJson(
        json['user'] as Map<String, dynamic>,
      );
    }

    return CompanyEmployeeProfileData(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      companyId: json['companyId']?.toString(),
      salary: json['salary']?.toString(),
      employmentType: json['employmentType']?.toString(),
      designation: json['designation']?.toString(),
      skill: json['skill']?.toString(),
      proposalPermission: json['proposalPermission'] is bool
          ? json['proposalPermission'] as bool
          : null,
      status: json['status']?.toString(),
      note: json['note']?.toString(),
      isActive: json['isActive'] is bool ? json['isActive'] as bool : null,
      joinedAt: json['joinedAt']?.toString(),
      quotationPermission: json['quotationPermission'] is bool
          ? json['quotationPermission'] as bool
          : null,
      terminatedAt: json['terminatedAt']?.toString(),
      verified: json['verified'] is bool ? json['verified'] as bool : null,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      user: parsedUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'companyId': companyId,
      'salary': salary,
      'employmentType': employmentType,
      'designation': designation,
      'skill': skill,
      'proposalPermission': proposalPermission,
      'status': status,
      'note': note,
      'isActive': isActive,
      'joinedAt': joinedAt,
      'quotationPermission': quotationPermission,
      'terminatedAt': terminatedAt,
      'verified': verified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'user': user?.toJson(),
    };
  }
}

class CompanyEmployeeUser {
  final String? name;
  final String? email;
  final String? avatar;
  final String? contact;
  final String? address;
  final String? latitude;
  final String? longitude;

  CompanyEmployeeUser({
    this.name,
    this.email,
    this.avatar,
    this.contact,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory CompanyEmployeeUser.fromJson(Map<String, dynamic> json) {
    return CompanyEmployeeUser(
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      avatar: json['avatar']?.toString(),
      contact: json['contact']?.toString(),
      address: json['address']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatar': avatar,
      'contact': contact,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
