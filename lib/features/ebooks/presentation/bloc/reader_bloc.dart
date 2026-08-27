import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_reading_progress_usecase.dart';
import '../../domain/usecases/save_reading_progress_usecase.dart';
import 'reader_event.dart';
import 'reader_state.dart';

class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  final SaveReadingProgressUseCase saveReadingProgressUseCase;
  final GetReadingProgressUseCase getReadingProgressUseCase;

  ReaderBloc({
    required this.saveReadingProgressUseCase,
    required this.getReadingProgressUseCase,
  }) : super(const ReaderInitial()) {
    on<OpenEbook>(_onOpenEbook);
    on<ChangePage>(_onChangePage);
    on<ToggleFullScreen>(_onToggleFullScreen);
    on<ZoomIn>(_onZoomIn);
    on<ZoomOut>(_onZoomOut);
  }

  Future<void> _onOpenEbook(OpenEbook event, Emitter<ReaderState> emit) async {
    emit(const ReaderLoading(message: 'Loading PDF document...'));

    final progressResult = await getReadingProgressUseCase(event.ebookId);
    final initialPage = progressResult.fold((_) => 1, (page) => page);

    emit(ReaderLoaded(
      ebookId: event.ebookId,
      pdfUrl: event.pdfUrl,
      pageNumber: initialPage,
      totalPages: 1,
      isFullScreen: false,
      zoomLevel: 1.0,
    ));
  }

  Future<void> _onChangePage(ChangePage event, Emitter<ReaderState> emit) async {
    if (state is ReaderLoaded) {
      final current = state as ReaderLoaded;
      emit(current.copyWith(
        pageNumber: event.pageNumber,
        totalPages: event.totalPages,
      ));

      await saveReadingProgressUseCase(SaveReadingProgressParams(
        ebookId: current.ebookId,
        pageNumber: event.pageNumber,
      ));
    }
  }

  void _onToggleFullScreen(ToggleFullScreen event, Emitter<ReaderState> emit) {
    if (state is ReaderLoaded) {
      final current = state as ReaderLoaded;
      emit(current.copyWith(isFullScreen: !current.isFullScreen));
    }
  }

  void _onZoomIn(ZoomIn event, Emitter<ReaderState> emit) {
    if (state is ReaderLoaded) {
      final current = state as ReaderLoaded;
      final newZoom = (current.zoomLevel + 0.25).clamp(1.0, 3.0);
      emit(current.copyWith(zoomLevel: newZoom));
    }
  }

  void _onZoomOut(ZoomOut event, Emitter<ReaderState> emit) {
    if (state is ReaderLoaded) {
      final current = state as ReaderLoaded;
      final newZoom = (current.zoomLevel - 0.25).clamp(1.0, 3.0);
      emit(current.copyWith(zoomLevel: newZoom));
    }
  }
}
