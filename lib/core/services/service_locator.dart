import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/api_consumer.dart';
import '../network/dio_client.dart';
import '../../features/ebooks/data/datasources/ebook_remote_data_source.dart';
import '../../features/ebooks/data/repositories/ebook_repository_impl.dart';
import '../../features/ebooks/domain/repositories/ebook_repository.dart';
import '../../features/ebooks/domain/usecases/delete_ebook_usecase.dart';
import '../../features/ebooks/domain/usecases/download_ebook_usecase.dart';
import '../../features/ebooks/domain/usecases/fetch_ebooks_usecase.dart';
import '../../features/ebooks/domain/usecases/get_ebook_details_usecase.dart';
import '../../features/ebooks/domain/usecases/search_ebooks_usecase.dart';
import '../../features/ebooks/domain/usecases/upload_ebook_usecase.dart';
import '../../features/ebooks/presentation/bloc/ebook_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // -----------------------
  // Core & Network
  // -----------------------
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<ApiConsumer>(() => DioClient(dio: sl()));

  // -----------------------
  // Data Sources
  // -----------------------
  sl.registerLazySingleton<EbookRemoteDataSource>(
    () => EbookRemoteDataSourceImpl(apiConsumer: sl()),
  );

  // -----------------------
  // Repositories
  // -----------------------
  sl.registerLazySingleton<EbookRepository>(
    () => EbookRepositoryImpl(remoteDataSource: sl()),
  );

  // -----------------------
  // Use Cases
  // -----------------------
  sl.registerLazySingleton(() => FetchEbooksUseCase(sl()));
  sl.registerLazySingleton(() => SearchEbooksUseCase(sl()));
  sl.registerLazySingleton(() => GetEbookDetailsUseCase(sl()));
  sl.registerLazySingleton(() => UploadEbookUseCase(sl()));
  sl.registerLazySingleton(() => DownloadEbookUseCase(sl()));
  sl.registerLazySingleton(() => DeleteEbookUseCase(sl()));

  // -----------------------
  // BLoC
  // -----------------------
  sl.registerFactory(
    () => EbookBloc(
      fetchEbooksUseCase: sl(),
      searchEbooksUseCase: sl(),
      getEbookDetailsUseCase: sl(),
      uploadEbookUseCase: sl(),
      downloadEbookUseCase: sl(),
      deleteEbookUseCase: sl(),
    ),
  );
}
