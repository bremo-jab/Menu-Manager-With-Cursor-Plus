class Restaurant {
  final String id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String instagram;
  final String facebook;
  final String twitter;
  final List<String> workingHours;
  final List<String> closingHours;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.instagram,
    required this.facebook,
    required this.twitter,
    required this.workingHours,
    required this.closingHours,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'instagram': instagram,
      'facebook': facebook,
      'twitter': twitter,
      'workingHours': workingHours,
      'closingHours': closingHours,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      website: map['website'] ?? '',
      instagram: map['instagram'] ?? '',
      facebook: map['facebook'] ?? '',
      twitter: map['twitter'] ?? '',
      workingHours: List<String>.from(map['workingHours'] ?? []),
      closingHours: List<String>.from(map['closingHours'] ?? []),
      ownerId: map['ownerId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
