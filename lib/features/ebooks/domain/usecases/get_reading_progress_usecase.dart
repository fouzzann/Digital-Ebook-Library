import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/ebook_repository.dart';

class GetReadingProgressUseCase implements UseCase<int, String> {
  final EbookRepository repository;

  GetReadingProgressUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(String ebookId) {
    return repository.getReadingProgress(ebookId);
  }
}
