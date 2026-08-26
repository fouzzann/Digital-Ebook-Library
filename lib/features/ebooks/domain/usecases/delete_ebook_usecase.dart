import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/ebook_repository.dart';

class DeleteEbookUseCase implements UseCase<void, String> {
  final EbookRepository repository;

  DeleteEbookUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteEbook(id);
  }
}
