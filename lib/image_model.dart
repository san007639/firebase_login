class ImageModel {
  final String id;
  final ImageUrls urls;

  ImageModel({required this.id, required this.urls});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] as String,
      urls: ImageUrls.fromJson(json['urls'] as Map<String, dynamic>),
    );
  }
}

class ImageUrls {
  final String raw;
  final String full;
  final String regular;
  final String small;
  final String thumb;

  ImageUrls({required this.raw, required this.full, required this.regular, required this.small, required this.thumb});

  factory ImageUrls.fromJson(Map<String, dynamic> json) {
    return ImageUrls(
      raw: json['raw'] as String,
      full: json['full'] as String,
      regular: json['regular'] as String,
      small: json['small'] as String,
      thumb: json['thumb'] as String,
    );
  }
}
