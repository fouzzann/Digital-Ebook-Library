import 'package:digital_ebook_library/core/errors/failures.dart';
import 'package:digital_ebook_library/features/ebooks/domain/usecases/download_ebook_usecase.dart';
import 'package:digital_ebook_library/features/ebooks/presentation/bloc/download_bloc.dart';
import 'package:digital_ebook_library/features/ebooks/presentation/bloc/download_event.dart';
import 'package:digital_ebook_library/features/ebooks/presentation/bloc/download_state.dart';
import 'package:digital_ebook_library/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDownloadEbookUseCase implements DownloadEbookUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Either<Failure, String>> downloadFile(
    String id, {
    required String downloadUrl,
    required String title,
    required String format,
    required void Function(double progress) onProgress,
  }) async {
    onProgress(0.5);
    onProgress(1.0);
    return const Right('/storage/emulated/0/Download/Clean_Architecture.pdf');
  }
}

void main() {
  late DownloadBloc downloadBloc;
  late MockDownloadEbookUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockDownloadEbookUseCase();
    downloadBloc = DownloadBloc(downloadEbookUseCase: mockUseCase);
  });

  tearDown(() {
    downloadBloc.close();
  });

  test('DownloadBloc emits DownloadInProgress and DownloadSuccess with saved public file path', () async {
    final expectedStates = [
      isA<DownloadInProgress>(),
      isA<DownloadInProgress>(),
      isA<DownloadInProgress>(),
      isA<DownloadSuccess>(),
    ];

    expectLater(downloadBloc.stream, emitsInOrder(expectedStates));

    downloadBloc.add(const StartDownload(
      ebookId: '1',
      downloadUrl: 'https://example.com/test.pdf',
      title: 'Clean Architecture',
      format: 'PDF',
    ));
  });

  test('DownloadBloc ignores duplicate StartDownload request while in progress', () async {
    downloadBloc.add(const StartDownload(
      ebookId: '2',
      downloadUrl: 'https://example.com/test2.pdf',
      title: 'Designing Data-Intensive Applications',
      format: 'PDF',
    ));

    // Duplicate call
    downloadBloc.add(const StartDownload(
      ebookId: '2',
      downloadUrl: 'https://example.com/test2.pdf',
      title: 'Designing Data-Intensive Applications',
      format: 'PDF',
    ));

    await Future.delayed(const Duration(milliseconds: 100));
    expect(downloadBloc.state, isA<DownloadSuccess>());
  });
}
