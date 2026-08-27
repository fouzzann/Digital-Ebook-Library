import 'package:equatable/equatable.dart';

abstract class ReaderEvent extends Equatable {
  const ReaderEvent();

  @override
  List<Object?> get props => [];
}

class OpenEbook extends ReaderEvent {
  final String ebookId;
  final String pdfUrl;

  const OpenEbook({required this.ebookId, required this.pdfUrl});

  @override
  List<Object?> get props => [ebookId, pdfUrl];
}

class LoadEbookPdf extends ReaderEvent {
  final String pdfUrl;

  const LoadEbookPdf(this.pdfUrl);

  @override
  List<Object?> get props => [pdfUrl];
}

class ChangePage extends ReaderEvent {
  final int pageNumber;
  final int totalPages;

  const ChangePage({required this.pageNumber, required this.totalPages});

  @override
  List<Object?> get props => [pageNumber, totalPages];
}

class SaveReadingProgress extends ReaderEvent {
  final String ebookId;
  final int pageNumber;

  const SaveReadingProgress({required this.ebookId, required this.pageNumber});

  @override
  List<Object?> get props => [ebookId, pageNumber];
}

class RestoreReadingProgress extends ReaderEvent {
  final String ebookId;

  const RestoreReadingProgress(this.ebookId);

  @override
  List<Object?> get props => [ebookId];
}

class ToggleFullScreen extends ReaderEvent {
  const ToggleFullScreen();
}

class ZoomIn extends ReaderEvent {
  const ZoomIn();
}

class ZoomOut extends ReaderEvent {
  const ZoomOut();
}
