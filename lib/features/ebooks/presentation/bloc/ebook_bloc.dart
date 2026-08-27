import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/entities/ebook_entity.dart';
import '../../domain/usecases/delete_ebook_usecase.dart';
import '../../domain/usecases/download_ebook_usecase.dart';
import '../../domain/usecases/fetch_ebooks_usecase.dart';
import '../../domain/usecases/get_ebook_details_usecase.dart';
import '../../domain/usecases/search_ebooks_usecase.dart';
import '../../domain/usecases/upload_ebook_usecase.dart';
import 'ebook_event.dart';
import 'ebook_state.dart';

class EbookBloc extends Bloc<EbookEvent, EbookState> {
  final FetchEbooksUseCase fetchEbooksUseCase;
  final SearchEbooksUseCase searchEbooksUseCase;
  final GetEbookDetailsUseCase getEbookDetailsUseCase;
  final UploadEbookUseCase uploadEbookUseCase;
  final DownloadEbookUseCase downloadEbookUseCase;
  final DeleteEbookUseCase deleteEbookUseCase;

  List<EbookEntity> _allEbooks = [];
  String _currentCategory = 'All';
  String _currentFormat = 'All';
  SortOption _currentSortOption = SortOption.recentlyUploaded;
  String _currentQuery = '';

  EbookBloc({
    required this.fetchEbooksUseCase,
    required this.searchEbooksUseCase,
    required this.getEbookDetailsUseCase,
    required this.uploadEbookUseCase,
    required this.downloadEbookUseCase,
    required this.deleteEbookUseCase,
  }) : super(const EbookInitial()) {
    on<FetchEbooks>(_onFetchEbooks);
    on<SearchEbooks>(_onSearchEbooks);
    on<FilterEbooksByCategory>(_onFilterCategory);
    on<FilterEbooksByFormat>(_onFilterFormat);
    on<SortEbooks>(_onSortEbooks);
    on<GetEbookDetails>(_onGetEbookDetails);
    on<UploadEbook>(_onUploadEbook);
    on<DownloadEbook>(_onDownloadEbook);
    on<DeleteEbook>(_onDeleteEbook);
  }

  Future<void> _onFetchEbooks(
    FetchEbooks event,
    Emitter<EbookState> emit,
  ) async {
    emit(const EbookLoading(message: 'Loading e-books...'));

    final result = await fetchEbooksUseCase(NoParams());

    result.fold(
      (failure) => emit(EbookError(message: failure.message)),
      (ebooks) {
        _allEbooks = ebooks;
        if (ebooks.isEmpty) {
          emit(const EbookEmpty(message: 'No e-books available in the library.'));
        } else {
          final filtered = _applyFilters(
            _allEbooks,
            _currentCategory,
            _currentFormat,
            _currentQuery,
            _currentSortOption,
          );
          emit(
            EbooksLoaded(
              ebooks: _allEbooks,
              filteredEbooks: filtered,
              selectedCategory: _currentCategory,
              selectedFormat: _currentFormat,
              sortOption: _currentSortOption,
              searchQuery: _currentQuery,
            ),
          );
        }
      },
    );
  }

  Future<void> _onSearchEbooks(
    SearchEbooks event,
    Emitter<EbookState> emit,
  ) async {
    _currentQuery = event.query;

    if (state is EbooksLoaded) {
      final filtered = _applyFilters(
        _allEbooks,
        _currentCategory,
        _currentFormat,
        _currentQuery,
        _currentSortOption,
      );
      if (filtered.isEmpty && _currentQuery.isNotEmpty) {
        emit(EbookEmpty(message: 'No e-books matching "${event.query}"'));
      } else {
        emit(
          EbooksLoaded(
            ebooks: _allEbooks,
            filteredEbooks: filtered,
            selectedCategory: _currentCategory,
            selectedFormat: _currentFormat,
            sortOption: _currentSortOption,
            searchQuery: _currentQuery,
          ),
        );
      }
      return;
    }

    emit(const EbookLoading());
    final result = await searchEbooksUseCase(event.query);
    result.fold(
      (failure) => emit(EbookError(message: failure.message)),
      (ebooks) {
        if (ebooks.isEmpty) {
          emit(EbookEmpty(message: 'No e-books matching "${event.query}"'));
        } else {
          final filtered = _applyFilters(
            ebooks,
            _currentCategory,
            _currentFormat,
            _currentQuery,
            _currentSortOption,
          );
          emit(
            EbooksLoaded(
              ebooks: ebooks,
              filteredEbooks: filtered,
              selectedCategory: _currentCategory,
              selectedFormat: _currentFormat,
              sortOption: _currentSortOption,
              searchQuery: _currentQuery,
            ),
          );
        }
      },
    );
  }

  void _onFilterCategory(
    FilterEbooksByCategory event,
    Emitter<EbookState> emit,
  ) {
    _currentCategory = event.category;
    final filtered = _applyFilters(
      _allEbooks,
      _currentCategory,
      _currentFormat,
      _currentQuery,
      _currentSortOption,
    );

    if (filtered.isEmpty) {
      emit(EbookEmpty(message: 'No e-books in category "${event.category}".'));
    } else {
      emit(
        EbooksLoaded(
          ebooks: _allEbooks,
          filteredEbooks: filtered,
          selectedCategory: _currentCategory,
          selectedFormat: _currentFormat,
          sortOption: _currentSortOption,
          searchQuery: _currentQuery,
        ),
      );
    }
  }

  void _onFilterFormat(
    FilterEbooksByFormat event,
    Emitter<EbookState> emit,
  ) {
    _currentFormat = event.format;
    final filtered = _applyFilters(
      _allEbooks,
      _currentCategory,
      _currentFormat,
      _currentQuery,
      _currentSortOption,
    );

    if (filtered.isEmpty) {
      emit(EbookEmpty(message: 'No e-books matching format "${event.format}".'));
    } else {
      emit(
        EbooksLoaded(
          ebooks: _allEbooks,
          filteredEbooks: filtered,
          selectedCategory: _currentCategory,
          selectedFormat: _currentFormat,
          sortOption: _currentSortOption,
          searchQuery: _currentQuery,
        ),
      );
    }
  }

  void _onSortEbooks(
    SortEbooks event,
    Emitter<EbookState> emit,
  ) {
    _currentSortOption = event.sortOption;
    final filtered = _applyFilters(
      _allEbooks,
      _currentCategory,
      _currentFormat,
      _currentQuery,
      _currentSortOption,
    );

    emit(
      EbooksLoaded(
        ebooks: _allEbooks,
        filteredEbooks: filtered,
        selectedCategory: _currentCategory,
        selectedFormat: _currentFormat,
        sortOption: _currentSortOption,
        searchQuery: _currentQuery,
      ),
    );
  }

  Future<void> _onGetEbookDetails(
    GetEbookDetails event,
    Emitter<EbookState> emit,
  ) async {
    emit(const EbookLoading(message: 'Fetching book details...'));
    final result = await getEbookDetailsUseCase(event.id);

    result.fold(
      (failure) => emit(EbookError(message: failure.message)),
      (ebook) => emit(EbookDetailLoaded(ebook: ebook)),
    );
  }

  Future<void> _onUploadEbook(
    UploadEbook event,
    Emitter<EbookState> emit,
  ) async {
    emit(const EbookUploading(message: 'Uploading e-book to library...'));

    final result = await uploadEbookUseCase(event.ebook);

    result.fold(
      (failure) => emit(EbookError(message: failure.message)),
      (uploadedEbook) {
        _allEbooks.insert(0, uploadedEbook);
        final filtered = _applyFilters(
          _allEbooks,
          _currentCategory,
          _currentFormat,
          _currentQuery,
          _currentSortOption,
        );
        emit(
          EbooksLoaded(
            ebooks: List.from(_allEbooks),
            filteredEbooks: filtered,
            selectedCategory: _currentCategory,
            selectedFormat: _currentFormat,
            sortOption: _currentSortOption,
            searchQuery: _currentQuery,
          ),
        );
        emit(const EbookOperationSuccess('E-book uploaded successfully!'));
      },
    );
  }

  Future<void> _onDownloadEbook(
    DownloadEbook event,
    Emitter<EbookState> emit,
  ) async {
    emit(EbookDownloading(ebookId: event.id, progress: 0.05));

    final result = await downloadEbookUseCase(event.id);

    await result.fold(
      (failure) async {
        emit(EbookError(message: failure.message));
      },
      (stream) async {
        await emit.forEach<double>(
          stream,
          onData: (progress) {
            if (progress >= 1.0) {
              _allEbooks = _allEbooks.map((e) {
                if (e.id == event.id) {
                  return e.copyWith(isDownloaded: true, downloadProgress: 1.0);
                }
                return e;
              }).toList();
            }
            return EbookDownloading(ebookId: event.id, progress: progress);
          },
          onError: (error, stackTrace) =>
              EbookError(message: 'Download failed: $error'),
        );

        final filtered = _applyFilters(
          _allEbooks,
          _currentCategory,
          _currentFormat,
          _currentQuery,
          _currentSortOption,
        );
        emit(
          EbooksLoaded(
            ebooks: List.from(_allEbooks),
            filteredEbooks: filtered,
            selectedCategory: _currentCategory,
            selectedFormat: _currentFormat,
            sortOption: _currentSortOption,
            searchQuery: _currentQuery,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteEbook(
    DeleteEbook event,
    Emitter<EbookState> emit,
  ) async {
    final result = await deleteEbookUseCase(event.id);

    result.fold(
      (failure) => emit(EbookError(message: failure.message)),
      (_) {
        _allEbooks.removeWhere((e) => e.id == event.id);
        final filtered = _applyFilters(
          _allEbooks,
          _currentCategory,
          _currentFormat,
          _currentQuery,
          _currentSortOption,
        );

        if (_allEbooks.isEmpty) {
          emit(const EbookEmpty(message: 'No e-books available in the library.'));
        } else {
          emit(
            EbooksLoaded(
              ebooks: List.from(_allEbooks),
              filteredEbooks: filtered,
              selectedCategory: _currentCategory,
              selectedFormat: _currentFormat,
              sortOption: _currentSortOption,
              searchQuery: _currentQuery,
            ),
          );
        }
        emit(const EbookOperationSuccess('E-book deleted successfully!'));
      },
    );
  }

  List<EbookEntity> _applyFilters(
    List<EbookEntity> ebooks,
    String category,
    String format,
    String query,
    SortOption sortOption,
  ) {
    final filtered = ebooks.where((ebook) {
      final matchesCategory = (category == 'All' || category.isEmpty) ||
          ebook.category.toLowerCase() == category.toLowerCase();
      final matchesFormat = (format == 'All' || format.isEmpty) ||
          ebook.format.toUpperCase() == format.toUpperCase();
      final matchesQuery = query.isEmpty ||
          ebook.title.toLowerCase().contains(query.toLowerCase()) ||
          ebook.author.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesFormat && matchesQuery;
    }).toList();

    switch (sortOption) {
      case SortOption.titleAsc:
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.authorAsc:
        filtered.sort((a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()));
        break;
      case SortOption.recentlyUploaded:
      default:
        break;
    }

    return filtered;
  }
}
