import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/download_ebook_usecase.dart';
import 'download_event.dart';
import 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadEbookUseCase downloadEbookUseCase;
  final Set<String> _activeDownloads = {};

  DownloadBloc({required this.downloadEbookUseCase}) : super(const DownloadInitial()) {
    on<StartDownload>(_onStartDownload);
  }

  Future<void> _onStartDownload(StartDownload event, Emitter<DownloadState> emit) async {
    // Prevent duplicate downloads while a download is already in progress
    if (_activeDownloads.contains(event.ebookId)) {
      return;
    }

    _activeDownloads.add(event.ebookId);
    emit(DownloadInProgress(ebookId: event.ebookId, progress: 0.05));

    final result = await downloadEbookUseCase.downloadFile(
      event.ebookId,
      downloadUrl: event.downloadUrl,
      title: event.title,
      format: event.format,
      onProgress: (progress) {
        if (!emit.isDone) {
          emit(DownloadInProgress(ebookId: event.ebookId, progress: progress));
        }
      },
    );

    _activeDownloads.remove(event.ebookId);

    result.fold(
      (failure) {
        emit(DownloadFailure(ebookId: event.ebookId, message: failure.message));
      },
      (savedFilePath) {
        emit(DownloadSuccess(
          ebookId: event.ebookId,
          savedFilePath: savedFilePath,
          title: event.title,
        ));
      },
    );
  }
}
