class Repack {
  final String title;
  final DateTime releaseDate;
  final String cover;
  final String genres;
  final String language;
  final String company;
  final String originalSize;
  final String repackSize;
  final Map<String, List<Map<String, String>>> downloadLinks;
  final String repackFeatures;
  final String description;
  List<String> screenshots;

  Repack({
    required this.title,
    required this.releaseDate,
    required this.cover,
    required this.genres,
    required this.language,
    required this.company,
    required this.originalSize,
    required this.repackSize,
    required this.downloadLinks,
    required this.repackFeatures,
    required this.description,
    required this.screenshots,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'releaseDate': releaseDate.toIso8601String(),
      'cover': cover,
      'genres': genres,
      'language': language,
      'company': company,
      'originalSize': originalSize,
      'repackSize': repackSize,
      'downloadLinks': downloadLinks,
      'repackFeatures': repackFeatures,
      'description': description,
      'screenshots': screenshots,
    };
  }

  factory Repack.fromJson(Map<String, dynamic> json) {
    return Repack(
      title: json['title'],
      releaseDate: DateTime.parse(json['releaseDate']),
      cover: json['cover'],
      genres: json['genres'],
      language: json['language'],
      company: json['company'],
      originalSize: json['originalSize'],
      repackSize: json['repackSize'],
      downloadLinks: (json['downloadLinks'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          List<Map<String, String>>.from(
            (value as List).map(
              (item) => Map<String, String>.from(item as Map),
            ),
          ),
        ),
      ),
      repackFeatures: json['repackFeatures'],
      description: json['description'],
      screenshots: List<String>.from(json['screenshots']),
    );
  }
}