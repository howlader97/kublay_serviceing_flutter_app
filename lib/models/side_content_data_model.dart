class SideContentDataModel {
  final String id;
  final String title;
  final String content;
  final String createdAt;
  final String updatedAt;

  const SideContentDataModel({
    this.id = "",
    this.title = "",
    this.content = "",
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory SideContentDataModel.fromJson(dynamic json) {
    if (json is! Map) return const SideContentDataModel();
    return SideContentDataModel(
      id: json["id"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "",
      content: json["content"]?.toString() ?? "",
      createdAt: json["createdAt"]?.toString() ?? "",
      updatedAt: json["updatedAt"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "content": content,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}
