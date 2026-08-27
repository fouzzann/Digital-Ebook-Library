import 'package:equatable/equatable.dart';
import '../../domain/entities/ebook_entity.dart';

enum SortOption {
  recentlyUploaded,
  titleAsc,
  authorAsc,
}

abstract class EbookEvent extends Equatable {
  const EbookEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch all e-books from the library
class FetchEbooks extends EbookEvent {
  const FetchEbooks();
}

/// Event to search e-books by keyword query
class SearchEbooks extends EbookEvent {
  final String query;

  const SearchEbooks(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to filter e-books by selected category
class FilterEbooksByCategory extends EbookEvent {
  final String category;

  const FilterEbooksByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Event to filter e-books by format (PDF, EPUB, MOBI, TXT)
class FilterEbooksByFormat extends EbookEvent {
  final String format;

  const FilterEbooksByFormat(this.format);

  @override
  List<Object?> get props => [format];
}

/// Event to sort e-books
class SortEbooks extends EbookEvent {
  final SortOption sortOption;

  const SortEbooks(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}

/// Event to fetch details of a specific e-book by ID
class GetEbookDetails extends EbookEvent {
  final String id;

  const GetEbookDetails(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to upload a new e-book to the library
class UploadEbook extends EbookEvent {
  final EbookEntity ebook;

  const UploadEbook(this.ebook);

  @override
  List<Object?> get props => [ebook];
}

/// Event to download an e-book by ID
class DownloadEbook extends EbookEvent {
  final String id;

  const DownloadEbook(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to delete an e-book from the library
class DeleteEbook extends EbookEvent {
  final String id;

  const DeleteEbook(this.id);

  @override
  List<Object?> get props => [id];
}
