import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/ebook_entity.dart';
import '../repositories/ebook_repository.dart';

class SearchEbooksUseCase implements UseCase<List<EbookEntity>, String> {
  final EbookRepository repository;

  SearchEbooksUseCase(this.repository);

  @override
  Future<Either<Failure, List<EbookEntity>>> call(String query) async {
    return await repository.searchEbooks(query);
  }
}
