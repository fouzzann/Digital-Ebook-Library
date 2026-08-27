import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/ebook_entity.dart';

abstract class EbookRepository {
  Future<Either<Failure, List<EbookEntity>>> fetchEbooks();
  Future<Either<Failure, List<EbookEntity>>> searchEbooks(String query);
  Future<Either<Failure, EbookEntity>> getEbookDetails(String id);
  Future<Either<Failure, EbookEntity>> uploadEbook(EbookEntity ebook);
  Future<Either<Failure, Stream<double>>> downloadEbook(String id);
  Future<Either<Failure, void>> deleteEbook(String id);
  Future<Either<Failure, void>> saveReadingProgress(String ebookId, int pageNumber);
  Future<Either<Failure, int>> getReadingProgress(String ebookId);
}
