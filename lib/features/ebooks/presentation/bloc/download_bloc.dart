import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/download_ebook_usecase.dart';
import 'download_event.dart';
import 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadEbookUseCase downloadEbookUseCase;

  DownloadBloc({required this.downloadEbookUseCase}) : super(const DownloadInitial()) {
    on<StartDownload>(_onStartDownload);
  }

  Future<void> _onStartDownload(StartDownload event, Emitter<DownloadState> emit) async {
    emit(DownloadInProgress(ebookId: event.ebookId, progress: 0.05));

    final result = await downloadEbookUseCase(event.ebookId);

    await result.fold(
      (failure) async {
        emit(DownloadFailure(ebookId: event.ebookId, message: failure.message));
      },
      (stream) async {
        await emit.forEach<double>(
          stream,
          onData: (progress) {
            if (progress >= 1.0) {
              return DownloadSuccess(
                ebookId: event.ebookId,
                savedFilePath: event.downloadUrl,
              );
            }
            return DownloadInProgress(ebookId: event.ebookId, progress: progress);
          },
          onError: (error, stackTrace) => DownloadFailure(
            ebookId: event.ebookId,
            message: 'Download failed: $error',
          ),
        );
      },
    );
  }
}
