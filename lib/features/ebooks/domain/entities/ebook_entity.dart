import 'package:equatable/equatable.dart';

class EbookEntity extends Equatable {
  final String id;
  final String title;
  final String author;
  final String description;
  final String category;
  final String coverUrl;
  final String downloadUrl;
  final String fileSize;
  final String format; // PDF, EPUB, MOBI
  final int publishedYear;
  final double rating;
  final bool isDownloaded;
  final double downloadProgress;

  const EbookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.category,
    required this.coverUrl,
    required this.downloadUrl,
    required this.fileSize,
    required this.format,
    required this.publishedYear,
    required this.rating,
    this.isDownloaded = false,
    this.downloadProgress = 0.0,
  });

  EbookEntity copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? category,
    String? coverUrl,
    String? downloadUrl,
    String? fileSize,
    String? format,
    int? publishedYear,
    double? rating,
    bool? isDownloaded,
    double? downloadProgress,
  }) {
    return EbookEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      category: category ?? this.category,
      coverUrl: coverUrl ?? this.coverUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fileSize: fileSize ?? this.fileSize,
      format: format ?? this.format,
      publishedYear: publishedYear ?? this.publishedYear,
      rating: rating ?? this.rating,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        description,
        category,
        coverUrl,
        downloadUrl,
        fileSize,
        format,
        publishedYear,
        rating,
        isDownloaded,
        downloadProgress,
      ];
}
