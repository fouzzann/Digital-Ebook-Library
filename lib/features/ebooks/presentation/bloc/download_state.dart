import 'package:equatable/equatable.dart';

abstract class DownloadState extends Equatable {
  const DownloadState();

  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadState {
  const DownloadInitial();
}

class DownloadInProgress extends DownloadState {
  final String ebookId;
  final double progress;
  final int percentage;
  final String statusMessage;

  DownloadInProgress({
    required this.ebookId,
    required this.progress,
    this.statusMessage = 'Downloading e-book...',
  }) : percentage = (progress * 100).clamp(0, 100).toInt();

  @override
  List<Object?> get props => [ebookId, progress, percentage, statusMessage];
}

class DownloadSuccess extends DownloadState {
  final String ebookId;
  final String savedFilePath;
  final String title;

  const DownloadSuccess({
    required this.ebookId,
    required this.savedFilePath,
    this.title = 'E-Book',
  });

  @override
  List<Object?> get props => [ebookId, savedFilePath, title];
}

class DownloadFailure extends DownloadState {
  final String ebookId;
  final String message;

  const DownloadFailure({
    required this.ebookId,
    required this.message,
  });

  @override
  List<Object?> get props => [ebookId, message];
}
