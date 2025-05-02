class RestaurantModel {
  final String id;
  final String name;
  final String type;
  final String description;
  final String city;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> workingDays;
  final Map<String, String> workingHours;
  final String logoUrl;
  final List<String> imagesUrls;
  final List<String> paymentMethods;
  final List<String> serviceOptions;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.workingDays,
    required this.workingHours,
    required this.logoUrl,
    required this.imagesUrls,
    required this.paymentMethods,
    required this.serviceOptions,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      workingDays: List<String>.from(json['workingDays'] as List),
      workingHours: Map<String, String>.from(json['workingHours'] as Map),
      logoUrl: json['logoUrl'] as String,
      imagesUrls: List<String>.from(json['imagesUrls'] as List),
      paymentMethods: List<String>.from(json['paymentMethods'] as List),
      serviceOptions: List<String>.from(json['serviceOptions'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'workingDays': workingDays,
      'workingHours': workingHours,
      'logoUrl': logoUrl,
      'imagesUrls': imagesUrls,
      'paymentMethods': paymentMethods,
      'serviceOptions': serviceOptions,
    };
  }
}
