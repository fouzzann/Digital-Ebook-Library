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
  final String statusMessage;

  const DownloadInProgress({
    required this.ebookId,
    required this.progress,
    this.statusMessage = 'Downloading e-book...',
  });

  @override
  List<Object?> get props => [ebookId, progress, statusMessage];
}

class DownloadSuccess extends DownloadState {
  final String ebookId;
  final String savedFilePath;

  const DownloadSuccess({
    required this.ebookId,
    required this.savedFilePath,
  });

  @override
  List<Object?> get props => [ebookId, savedFilePath];
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
