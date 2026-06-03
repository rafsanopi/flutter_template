import 'package:get/get.dart';

enum AppErrorType {
  noInternet,
  unauthorized,
  forbidden,
  notFound,
  timeout,
  badRequest,
  server,
  badResponse,
  unknown,
}

class AppErrorInfo {
  const AppErrorInfo({
    required this.type,
    required this.title,
    required this.message,
    this.statusCode,
    this.error,
    this.stackTrace,
  });

  final AppErrorType type;
  final String title;
  final String message;
  final int? statusCode;
  final Object? error;
  final StackTrace? stackTrace;

  bool get blocksUi => type == AppErrorType.noInternet;

  factory AppErrorInfo.noInternet() {
    return const AppErrorInfo(
      type: AppErrorType.noInternet,
      title: 'No internet connection',
      message: 'Please check your connection and try again.',
      statusCode: 503,
    );
  }

  factory AppErrorInfo.unauthorized() {
    return const AppErrorInfo(
      type: AppErrorType.unauthorized,
      title: 'Session expired',
      message: 'Please sign in again to continue.',
      statusCode: 401,
    );
  }

  factory AppErrorInfo.timeout({Object? error, StackTrace? stackTrace}) {
    return AppErrorInfo(
      type: AppErrorType.timeout,
      title: 'Request timed out',
      message: 'The server took too long to respond. Please try again.',
      statusCode: 408,
      error: error,
      stackTrace: stackTrace,
    );
  }

  factory AppErrorInfo.badResponse({Object? error, StackTrace? stackTrace}) {
    return AppErrorInfo(
      type: AppErrorType.badResponse,
      title: 'Invalid response',
      message: 'The server returned data that could not be processed.',
      error: error,
      stackTrace: stackTrace,
    );
  }

  factory AppErrorInfo.unknown({Object? error, StackTrace? stackTrace}) {
    return AppErrorInfo(
      type: AppErrorType.unknown,
      title: 'Something went wrong',
      message: 'Please try again in a moment.',
      error: error,
      stackTrace: stackTrace,
    );
  }

  factory AppErrorInfo.fromResponse(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    final message = messageFromBody(response.body, response.statusText);

    if (statusCode == 401) {
      return AppErrorInfo.unauthorized();
    }

    if (statusCode == 403) {
      return AppErrorInfo(
        type: AppErrorType.forbidden,
        title: 'Access denied',
        message: message.isNotEmpty ? message : 'You do not have permission.',
        statusCode: statusCode,
      );
    }

    if (statusCode == 404) {
      return AppErrorInfo(
        type: AppErrorType.notFound,
        title: 'Not found',
        message: message.isNotEmpty ? message : 'Requested data was not found.',
        statusCode: statusCode,
      );
    }

    if (statusCode == 408) {
      return AppErrorInfo.timeout();
    }

    if (statusCode == 503 && message.toLowerCase().contains('internet')) {
      return AppErrorInfo.noInternet();
    }

    if (statusCode >= 500) {
      return AppErrorInfo(
        type: AppErrorType.server,
        title: 'Server error',
        message: message.isNotEmpty
            ? message
            : 'The server is unavailable. Please try again later.',
        statusCode: statusCode,
      );
    }

    if (statusCode >= 400) {
      return AppErrorInfo(
        type: AppErrorType.badRequest,
        title: 'Request failed',
        message: message.isNotEmpty ? message : 'Please check and try again.',
        statusCode: statusCode,
      );
    }

    return AppErrorInfo.unknown();
  }

  static String messageFromBody(dynamic body, String? statusText) {
    if (body is Map) {
      final value = body['message'] ?? body['error'] ?? body['detail'];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value is List && value.isNotEmpty) {
        return value.join('\n');
      }
    }

    if (body is String && body.trim().isNotEmpty) {
      return body.trim();
    }

    return statusText?.trim() ?? '';
  }
}
