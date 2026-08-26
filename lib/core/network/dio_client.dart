import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'api_consumer.dart';

class DioClient implements ApiConsumer {
  final Dio dio;

  DioClient({required this.dio}) {
    dio.options
      ..baseUrl = ApiConstants.baseUrl
      ..connectTimeout = const Duration(milliseconds: ApiConstants.connectTimeoutMs)
      ..receiveTimeout = const Duration(milliseconds: ApiConstants.receiveTimeoutMs)
      ..headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.post(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<dynamic> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.delete(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Never _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        throw const NetworkException(message: 'Connection timed out. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          throw const NotFoundException(message: 'Requested resource was not found.');
        }
        throw ServerException(
          message: error.response?.data?['message'] ?? 'Server error occurred',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        throw const ServerException(message: 'Request was cancelled.');
      default:
        throw const ServerException(message: 'An unexpected network error occurred.');
    }
  }
}
