class UserProfileModel {
  final String? message;
  final UserData? data;

  UserProfileModel({this.message, this.data});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      message: json["message"]?.toString(),
      data: json["data"] != null
          ? UserData.fromJson(json["data"] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {"message": message, "data": data?.toJson()};
  }
}

class UserData {
  final String? id;
  final String? name;
  final String? email;
  final String? address;
  final String? contact;
  final String? avatar;
  final String? role;
  final String? takenServices;
  final double? latitude;
  final double? longitude;

  UserData({
    this.id,
    this.name,
    this.email,
    this.address,
    this.contact,
    this.avatar,
    this.role,
    this.takenServices,
    this.latitude,
    this.longitude,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json["id"]?.toString(),
      name: json["name"]?.toString(),
      email: json["email"]?.toString(),
      address: json["address"]?.toString(),
      contact: json["contact"]?.toString(),
      avatar: json["avatar"]?.toString(),
      role: json["role"]?.toString(),
      takenServices: json["taken_services"]?.toString(),
      latitude: double.tryParse(json["latitude"]?.toString() ?? ""),
      longitude: double.tryParse(json["longitude"]?.toString() ?? ""),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "address": address,
      "contact": contact,
      "avatar": avatar,
      "role": role,
      "taken_services": takenServices,
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}
