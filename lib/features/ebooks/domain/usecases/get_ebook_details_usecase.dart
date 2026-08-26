import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/ebook_entity.dart';
import '../repositories/ebook_repository.dart';

class GetEbookDetailsUseCase implements UseCase<EbookEntity, String> {
  final EbookRepository repository;

  GetEbookDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, EbookEntity>> call(String id) async {
    return await repository.getEbookDetails(id);
  }
}
