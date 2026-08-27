import 'package:equatable/equatable.dart';

abstract class DownloadEvent extends Equatable {
  const DownloadEvent();

  @override
  List<Object?> get props => [];
}

class StartDownload extends DownloadEvent {
  final String ebookId;
  final String downloadUrl;
  final String title;
  final String format;

  const StartDownload({
    required this.ebookId,
    required this.downloadUrl,
    required this.title,
    this.format = 'PDF',
  });

  @override
  List<Object?> get props => [ebookId, downloadUrl, title, format];
}

class CancelDownload extends DownloadEvent {
  final String ebookId;

  const CancelDownload(this.ebookId);

  @override
  List<Object?> get props => [ebookId];
}
