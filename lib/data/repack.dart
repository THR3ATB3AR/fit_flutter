import 'dart:convert';

class Repack {
  final String title;
  final String url;
  final DateTime releaseDate;
  String cover;
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
    required this.url,
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
      'url': url,
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

  factory Repack.fromSqlite(Map<String, dynamic> row) {
    return Repack(
      title: row['title'],
      url: row['url'],
      releaseDate: DateTime.parse(row['releaseDate']),
      cover: row['cover'],
      genres: row['genres'],
      language: row['language'],
      company: row['company'],
      originalSize: row['originalSize'],
      repackSize: row['repackSize'],
      downloadLinks: (jsonDecode(row['downloadLinks']) as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          List<Map<String, String>>.from(
            (value as List).map(
              (item) => Map<String, String>.from(item as Map<String, dynamic>),
            ),
          ),
        ),
      ),
      repackFeatures: row['repackFeatures'],
      description: row['description'],
      screenshots: List<String>.from(jsonDecode(row['screenshots'])),
    );
  }
}