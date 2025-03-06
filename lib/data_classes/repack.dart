class Repack {
  final String title;
  final DateTime releaseDate;
  final String cover;
  final String genres;
  final String language;
  final String company;
  final String originalSize;
  final String repackSize;
  final Map<String, List<Map<String, String>>>downloadLinks;
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

}