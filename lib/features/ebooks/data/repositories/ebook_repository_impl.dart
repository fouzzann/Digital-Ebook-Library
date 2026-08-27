import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/ebook_entity.dart';
import '../../domain/repositories/ebook_repository.dart';
import '../datasources/ebook_local_data_source.dart';
import '../datasources/ebook_remote_data_source.dart';
import '../models/ebook_model.dart';

class EbookRepositoryImpl implements EbookRepository {
  final EbookRemoteDataSource remoteDataSource;
  final EbookLocalDataSource localDataSource;

  EbookRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<EbookEntity>>> fetchEbooks() async {
    try {
      final ebooks = await remoteDataSource.fetchEbooks();
      return Right(ebooks);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch e-books: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<EbookEntity>>> searchEbooks(String query) async {
    try {
      final ebooks = await remoteDataSource.searchEbooks(query);
      return Right(ebooks);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to search e-books: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, EbookEntity>> getEbookDetails(String id) async {
    try {
      final ebook = await remoteDataSource.getEbookDetails(id);
      return Right(ebook);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to load e-book details: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, EbookEntity>> uploadEbook(EbookEntity ebook) async {
    try {
      final model = EbookModel.fromEntity(ebook);
      final uploadedBook = await remoteDataSource.uploadEbook(model);
      return Right(uploadedBook);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to upload e-book: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Stream<double>>> downloadEbook(String id) async {
    try {
      final stream = await remoteDataSource.downloadEbook(id);
      return Right(stream);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to download e-book: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> downloadEbookFile(
    String id, {
    required String downloadUrl,
    required String title,
    required String format,
    required void Function(double progress) onProgress,
  }) async {
    try {
      final savedPath = await remoteDataSource.downloadEbookFile(
        id,
        downloadUrl: downloadUrl,
        title: title,
        format: format,
        onProgress: onProgress,
      );
      return Right(savedPath);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to save e-book file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEbook(String id) async {
    try {
      await remoteDataSource.deleteEbook(id);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to delete e-book: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveReadingProgress(String ebookId, int pageNumber) async {
    try {
      await localDataSource.saveReadingProgress(ebookId, pageNumber);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save reading progress: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getReadingProgress(String ebookId) async {
    try {
      final page = await localDataSource.getReadingProgress(ebookId);
      return Right(page);
    } catch (e) {
      return const Right(1);
    }
  }
}
