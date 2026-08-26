import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/ebook_entity.dart';
import '../repositories/ebook_repository.dart';

class FetchEbooksUseCase implements UseCase<List<EbookEntity>, NoParams> {
  final EbookRepository repository;

  FetchEbooksUseCase(this.repository);

  @override
  Future<Either<Failure, List<EbookEntity>>> call(NoParams params) async {
    return await repository.fetchEbooks();
  }
}
