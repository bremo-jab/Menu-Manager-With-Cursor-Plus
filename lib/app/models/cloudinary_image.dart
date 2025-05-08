class CloudinaryImage {
  final String url;
  final String publicId;

  CloudinaryImage({
    required this.url,
    required this.publicId,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'publicId': publicId,
    };
  }

  factory CloudinaryImage.fromMap(Map<String, dynamic> map) {
    return CloudinaryImage(
      url: map['url'] as String,
      publicId: map['publicId'] as String,
    );
  }
}
