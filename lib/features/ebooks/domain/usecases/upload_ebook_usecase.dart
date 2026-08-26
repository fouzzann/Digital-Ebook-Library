import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/ebook_entity.dart';
import '../repositories/ebook_repository.dart';

class UploadEbookUseCase implements UseCase<EbookEntity, EbookEntity> {
  final EbookRepository repository;

  UploadEbookUseCase(this.repository);

  @override
  Future<Either<Failure, EbookEntity>> call(EbookEntity ebook) async {
    return await repository.uploadEbook(ebook);
  }
}
