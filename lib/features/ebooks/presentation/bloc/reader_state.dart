import 'package:equatable/equatable.dart';

abstract class ReaderState extends Equatable {
  const ReaderState();

  @override
  List<Object?> get props => [];
}

class ReaderInitial extends ReaderState {
  const ReaderInitial();
}

class ReaderLoading extends ReaderState {
  final String message;

  const ReaderLoading({this.message = 'Loading document...'});

  @override
  List<Object?> get props => [message];
}

class ReaderLoaded extends ReaderState {
  final String ebookId;
  final String pdfUrl;
  final int pageNumber;
  final int totalPages;
  final bool isFullScreen;
  final double zoomLevel;

  const ReaderLoaded({
    required this.ebookId,
    required this.pdfUrl,
    required this.pageNumber,
    required this.totalPages,
    this.isFullScreen = false,
    this.zoomLevel = 1.0,
  });

  ReaderLoaded copyWith({
    String? ebookId,
    String? pdfUrl,
    int? pageNumber,
    int? totalPages,
    bool? isFullScreen,
    double? zoomLevel,
  }) {
    return ReaderLoaded(
      ebookId: ebookId ?? this.ebookId,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      pageNumber: pageNumber ?? this.pageNumber,
      totalPages: totalPages ?? this.totalPages,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      zoomLevel: zoomLevel ?? this.zoomLevel,
    );
  }

  @override
  List<Object?> get props => [
        ebookId,
        pdfUrl,
        pageNumber,
        totalPages,
        isFullScreen,
        zoomLevel,
      ];
}

class ReaderError extends ReaderState {
  final String message;
  final String pdfUrl;

  const ReaderError({required this.message, required this.pdfUrl});

  @override
  List<Object?> get props => [message, pdfUrl];
}
