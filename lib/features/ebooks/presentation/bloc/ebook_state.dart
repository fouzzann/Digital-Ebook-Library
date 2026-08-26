import 'package:equatable/equatable.dart';
import '../../domain/entities/ebook_entity.dart';

abstract class EbookState extends Equatable {
  const EbookState();

  @override
  List<Object?> get props => [];
}

/// Initial state when BLoC is created
class EbookInitial extends EbookState {
  const EbookInitial();
}

/// Loading state during fetch/search operations
class EbookLoading extends EbookState {
  final String? message;

  const EbookLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Loaded state containing list of ebooks and category filter state
class EbooksLoaded extends EbookState {
  final List<EbookEntity> ebooks;
  final List<EbookEntity> filteredEbooks;
  final String selectedCategory;
  final String searchQuery;

  const EbooksLoaded({
    required this.ebooks,
    required this.filteredEbooks,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  EbooksLoaded copyWith({
    List<EbookEntity>? ebooks,
    List<EbookEntity>? filteredEbooks,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return EbooksLoaded(
      ebooks: ebooks ?? this.ebooks,
      filteredEbooks: filteredEbooks ?? this.filteredEbooks,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [ebooks, filteredEbooks, selectedCategory, searchQuery];
}

/// Empty state when no ebooks match criteria
class EbookEmpty extends EbookState {
  final String message;

  const EbookEmpty({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Uploading state when uploading an ebook
class EbookUploading extends EbookState {
  final String message;

  const EbookUploading({this.message = 'Uploading e-book...'});

  @override
  List<Object?> get props => [message];
}

/// Downloading state with real-time progress ratio
class EbookDownloading extends EbookState {
  final String ebookId;
  final double progress;

  const EbookDownloading({required this.ebookId, required this.progress});

  @override
  List<Object?> get props => [ebookId, progress];
}

/// State when a single ebook details are loaded
class EbookDetailLoaded extends EbookState {
  final EbookEntity ebook;

  const EbookDetailLoaded({required this.ebook});

  @override
  List<Object?> get props => [ebook];
}

/// Success state for one-off operations (Upload, Delete, Download finished)
class EbookOperationSuccess extends EbookState {
  final String message;

  const EbookOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state containing actionable error details
class EbookError extends EbookState {
  final String message;
  final String? code;

  const EbookError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}
