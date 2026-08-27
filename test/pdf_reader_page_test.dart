import 'package:digital_ebook_library/core/services/service_locator.dart';
import 'package:digital_ebook_library/features/ebooks/domain/usecases/get_reading_progress_usecase.dart';
import 'package:digital_ebook_library/features/ebooks/domain/usecases/save_reading_progress_usecase.dart';
import 'package:digital_ebook_library/features/ebooks/presentation/bloc/reader_bloc.dart';
import 'package:digital_ebook_library/features/ebooks/presentation/bloc/reader_event.dart';
import 'package:digital_ebook_library/features/ebooks/presentation/bloc/reader_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await initServiceLocator();
  });

  test('ReaderBloc emits ReaderLoaded state and persists reading progress', () async {
    final saveUseCase = sl<SaveReadingProgressUseCase>();
    final getUseCase = sl<GetReadingProgressUseCase>();
    final bloc = ReaderBloc(
      saveReadingProgressUseCase: saveUseCase,
      getReadingProgressUseCase: getUseCase,
    );

    expect(bloc.state, isA<ReaderInitial>());

    bloc.add(const OpenEbook(ebookId: 'test_book_1', pdfUrl: 'https://example.com/test.pdf'));
    await Future.delayed(const Duration(milliseconds: 50));

    expect(bloc.state, isA<ReaderLoaded>());
    final loaded = bloc.state as ReaderLoaded;
    expect(loaded.ebookId, 'test_book_1');
    expect(loaded.pageNumber, 1);

    bloc.add(const ChangePage(pageNumber: 5, totalPages: 20));
    await Future.delayed(const Duration(milliseconds: 50));

    final updated = bloc.state as ReaderLoaded;
    expect(updated.pageNumber, 5);
    expect(updated.totalPages, 20);

    // Verify progress restoration
    final savedPage = await getUseCase('test_book_1');
    expect(savedPage.fold((_) => 0, (page) => page), 5);
  });
}
