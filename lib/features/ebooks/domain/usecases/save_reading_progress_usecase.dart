import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/ebook_repository.dart';

class SaveReadingProgressParams extends Equatable {
  final String ebookId;
  final int pageNumber;

  const SaveReadingProgressParams({
    required this.ebookId,
    required this.pageNumber,
  });

  @override
  List<Object?> get props => [ebookId, pageNumber];
}

class SaveReadingProgressUseCase implements UseCase<void, SaveReadingProgressParams> {
  final EbookRepository repository;

  SaveReadingProgressUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveReadingProgressParams params) {
    return repository.saveReadingProgress(params.ebookId, params.pageNumber);
  }
}
