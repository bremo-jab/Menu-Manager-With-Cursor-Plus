class MenuCategoryModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final int order;
  final String imageUrl;

  MenuCategoryModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.order,
    required this.imageUrl,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'order': order,
      'imageUrl': imageUrl,
    };
  }
}
