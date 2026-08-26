import '../../domain/entities/ebook_entity.dart';

class EbookModel extends EbookEntity {
  const EbookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.description,
    required super.category,
    required super.coverUrl,
    required super.downloadUrl,
    required super.fileSize,
    required super.format,
    required super.publishedYear,
    required super.rating,
    super.isDownloaded,
    super.downloadProgress,
  });

  factory EbookModel.fromJson(Map<String, dynamic> json) {
    return EbookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      coverUrl: json['coverUrl'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String? ?? '',
      fileSize: json['fileSize'] as String? ?? '0 MB',
      format: json['format'] as String? ?? 'PDF',
      publishedYear: (json['publishedYear'] as num?)?.toInt() ?? 2024,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      downloadProgress: (json['downloadProgress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'category': category,
      'coverUrl': coverUrl,
      'downloadUrl': downloadUrl,
      'fileSize': fileSize,
      'format': format,
      'publishedYear': publishedYear,
      'rating': rating,
      'isDownloaded': isDownloaded,
      'downloadProgress': downloadProgress,
    };
  }

  factory EbookModel.fromEntity(EbookEntity entity) {
    return EbookModel(
      id: entity.id,
      title: entity.title,
      author: entity.author,
      description: entity.description,
      category: entity.category,
      coverUrl: entity.coverUrl,
      downloadUrl: entity.downloadUrl,
      fileSize: entity.fileSize,
      format: entity.format,
      publishedYear: entity.publishedYear,
      rating: entity.rating,
      isDownloaded: entity.isDownloaded,
      downloadProgress: entity.downloadProgress,
    );
  }
}
