import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/ebook_repository.dart';

class DownloadEbookUseCase implements UseCase<Stream<double>, String> {
  final EbookRepository repository;

  DownloadEbookUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<double>>> call(String id) async {
    return await repository.downloadEbook(id);
  }

  Future<Either<Failure, String>> downloadFile(
    String id, {
    required String downloadUrl,
    required String title,
    required String format,
    required void Function(double progress) onProgress,
  }) async {
    return await repository.downloadEbookFile(
      id,
      downloadUrl: downloadUrl,
      title: title,
      format: format,
      onProgress: onProgress,
    );
  }
}
