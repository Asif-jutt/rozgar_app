import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';

/// High-level REST API service for third-party API integrations
/// Provides methods for common HTTP operations with error handling
class ApiService {
  late final DioClient _dioClient;

  ApiService._() {
    _dioClient = DioClient.base();
  }

  static final ApiService _instance = ApiService._();

  factory ApiService() {
    return _instance;
  }

  /// Performs a GET request to the specified endpoint
  /// [endpoint]: API endpoint URL
  /// [headers]: Optional additional headers
  /// [queryParameters]: Optional query parameters
  /// Returns the response data
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        endpoint,
        options: Options(headers: headers),
        queryParameters: queryParameters,
      );

      _validateResponse(response);
      AppLogger.i('GET $endpoint → ${response.statusCode}');
      return response.data;
    } on DioException catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  /// Performs a POST request to the specified endpoint
  /// [endpoint]: API endpoint URL
  /// [body]: Request body data
  /// [headers]: Optional additional headers
  /// Returns the response data
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );

      _validateResponse(response);
      AppLogger.i('POST $endpoint → ${response.statusCode}');
      return response.data;
    } on DioException catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  /// Performs a PUT request to the specified endpoint
  /// [endpoint]: API endpoint URL
  /// [body]: Request body data
  /// [headers]: Optional additional headers
  /// Returns the response data
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );

      _validateResponse(response);
      AppLogger.i('PUT $endpoint → ${response.statusCode}');
      return response.data;
    } on DioException catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  /// Performs a PATCH request to the specified endpoint
  /// [endpoint]: API endpoint URL
  /// [body]: Request body data
  /// [headers]: Optional additional headers
  /// Returns the response data
  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dioClient.dio.patch(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );

      _validateResponse(response);
      AppLogger.i('PATCH $endpoint → ${response.statusCode}');
      return response.data;
    } on DioException catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  /// Performs a DELETE request to the specified endpoint
  /// [endpoint]: API endpoint URL
  /// [headers]: Optional additional headers
  /// Returns the response data
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dioClient.dio.delete(
        endpoint,
        options: Options(headers: headers),
      );

      _validateResponse(response);
      AppLogger.i('DELETE $endpoint → ${response.statusCode}');
      return response.data;
    } on DioException catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  /// Downloads a file from the specified endpoint
  /// [endpoint]: API endpoint URL
  /// [savePath]: Local file path to save to
  /// [onReceiveProgress]: Callback for download progress
  Future<void> download(
    String endpoint,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dioClient.dio.download(
        endpoint,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
      AppLogger.i('Download complete: $endpoint → $savePath');
    } on DioException catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  /// Uploads a file to the specified endpoint
  /// [endpoint]: API endpoint URL
  /// [filePath]: Path to file to upload
  /// [fieldName]: Form field name for the file
  /// [onSendProgress]: Callback for upload progress
  /// Returns the response data
  Future<dynamic> upload(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    ProgressCallback? onSendProgress,
    Map<String, String>? additionalFields,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalFields,
      });

      final response = await _dioClient.dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
      );

      _validateResponse(response);
      AppLogger.i('Upload complete: $filePath → $endpoint');
      return response.data;
    } on DioException catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  /// Performs a GraphQL query request
  /// [endpoint]: GraphQL endpoint URL
  /// [query]: GraphQL query string
  /// [variables]: Optional query variables
  /// Returns the response data
  Future<dynamic> graphql(
    String endpoint,
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    try {
      final body = {
        'query': query,
        if (variables != null) 'variables': variables,
      };

      final response = await _dioClient.dio.post(
        endpoint,
        data: jsonEncode(body),
        options: Options(contentType: 'application/json'),
      );

      _validateResponse(response);
      AppLogger.i('GraphQL query executed on $endpoint');
      return response.data;
    } on DioException catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  /// Validates HTTP response status code
  void _validateResponse(Response response) {
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw ApiException(
        statusCode: response.statusCode ?? 0,
        message: response.statusMessage ?? 'Unknown error',
        response: response,
      );
    }
  }

  /// Handles API errors and logs them
  void _handleError(DioException error, StackTrace st) {
    final message = _getErrorMessage(error);
    AppLogger.e('API Error: $message', st);
  }

  /// Gets human-readable error message from DioException
  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Bad response: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.unknown:
        return error.message ?? 'Unknown error';
      case DioExceptionType.badCertificate:
        return 'Bad certificate';
      case DioExceptionType.connectionError:
        return 'Connection error';
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Response? response;

  ApiException({
    required this.statusCode,
    required this.message,
    this.response,
  });

  @override
  String toString() => 'ApiException: [$statusCode] $message';
}

/// Model for paginated API responses
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    this.hasNextPage = false,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    final data =
        (json['data'] as List?)?.map((item) => fromJson(item)).toList() ?? [];
    return PaginatedResponse(
      data: data,
      currentPage: json['currentPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }
}
