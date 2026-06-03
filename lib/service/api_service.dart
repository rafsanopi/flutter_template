import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:templete/global/app_status/app_error_info.dart';
import 'package:templete/global/app_status/app_status_controller.dart';
import 'package:templete/global/model/response_model.dart';
import 'package:templete/helper/local_db/local_db.dart';
import 'package:templete/utils/app_const/app_const.dart';
import 'package:templete/utils/logger/logger.dart';

final log = logger(ApiClient);

typedef ServerResponse<T> = Future<Either<ErrorResponseModel, T>>;

const String noInternetConnection = 'No internet connection.';

Map<String, String> basicHeaderInfo() {
  return {
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.contentTypeHeader: 'application/json',
  };
}

Future<Map<String, String>> bearerHeaderInfo() async {
  final token = await SharePrefsHelper.getString(AppConstants.token);
  return {
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token',
  };
}

class ApiClient {
  Future<Response<dynamic>> get({
    required String url,
    bool isBasic = false,
    int duration = 30,
    bool showResult = false,
    BuildContext? context,
  }) {
    return _sendJsonRequest(
      method: 'GET',
      url: url,
      isBasic: isBasic,
      duration: duration,
      showResult: showResult,
    );
  }

  Future<Response<dynamic>> post({
    required String url,
    bool isBasic = false,
    Map<String, dynamic>? body,
    required BuildContext context,
    int duration = 30,
    bool showResult = true,
  }) {
    return _sendJsonRequest(
      method: 'POST',
      url: url,
      body: body,
      isBasic: isBasic,
      duration: duration,
      showResult: showResult,
    );
  }

  Future<Response<dynamic>> patch({
    required String url,
    bool isBasic = false,
    Map<String, dynamic>? body,
    int duration = 30,
    bool showResult = false,
  }) {
    return _sendJsonRequest(
      method: 'PATCH',
      url: url,
      body: body,
      isBasic: isBasic,
      duration: duration,
      showResult: showResult,
    );
  }

  Future<Map<String, dynamic>?> paramGet({
    String? url,
    bool? isBasic,
    Map<String, String>? body,
    int code = 200,
    int duration = 15,
    bool showResult = false,
  }) async {
    if (url == null || url.isEmpty) {
      _reportError(AppErrorInfo.unknown());
      return null;
    }

    final requestUrl = Uri.parse(url).replace(queryParameters: body).toString();
    final response = await _sendJsonRequest(
      method: 'GET',
      url: requestUrl,
      isBasic: isBasic ?? false,
      duration: duration,
      showResult: showResult,
    );

    return response.statusCode == code ? _bodyAsMap(response.body) : null;
  }

  Future<Response<dynamic>> multipartRequest({
    required String url,
    required String reqType,
    bool isBasic = false,
    Map<String, String>? body,
    required List<MultipartBody> multipartBody,
    bool showResult = true,
    int duration = 30,
  }) async {
    if (!await _ensureInternet()) {
      return _failureResponse(AppErrorInfo.noInternet());
    }

    try {
      final request = http.MultipartRequest(reqType, Uri.parse(url))
        ..fields.addAll(body ?? {})
        ..headers.addAll(
          isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
        );

      for (final item in multipartBody) {
        if (item.file.path.isEmpty) {
          continue;
        }

        final mimeType = lookupMimeType(item.file.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            item.key,
            item.file.path,
            contentType: mimeType == null ? null : MediaType.parse(mimeType),
          ),
        );
      }

      if (showResult) {
        _logRequest(reqType, url, body);
      }

      final streamedResponse = await request.send().timeout(
        Duration(seconds: duration),
      );
      final response = await http.Response.fromStream(streamedResponse);
      final apiResponse = _toGetResponse(response);

      if (showResult) {
        _logResponse(apiResponse);
      }

      await _handleResponse(apiResponse);
      return apiResponse;
    } catch (error, stackTrace) {
      return _handleException(error, stackTrace, url);
    }
  }

  Future<Map<String, dynamic>?> delete({
    String? url,
    bool? isBasic,
    int code = 202,
    bool isLogout = false,
    int duration = 15,
    bool showResult = false,
  }) async {
    if (url == null || url.isEmpty) {
      _reportError(AppErrorInfo.unknown());
      return null;
    }

    final response = await _sendJsonRequest(
      method: 'DELETE',
      url: url,
      isBasic: isBasic ?? false,
      duration: duration,
      showResult: showResult,
    );

    return response.statusCode == code ? _bodyAsMap(response.body) : null;
  }

  Future<Map<String, dynamic>?> put({
    String? url,
    bool? isBasic,
    Map<String, dynamic>? body,
    int code = 202,
    int duration = 15,
    bool showResult = false,
  }) async {
    if (url == null || url.isEmpty) {
      _reportError(AppErrorInfo.unknown());
      return null;
    }

    final response = await _sendJsonRequest(
      method: 'PUT',
      url: url,
      body: body,
      isBasic: isBasic ?? false,
      duration: duration,
      showResult: showResult,
    );

    return response.statusCode == code ? _bodyAsMap(response.body) : null;
  }

  Future<Response<dynamic>> _sendJsonRequest({
    required String method,
    required String url,
    bool isBasic = false,
    Object? body,
    int duration = 30,
    bool showResult = false,
  }) async {
    if (!await _ensureInternet()) {
      return _failureResponse(AppErrorInfo.noInternet());
    }

    try {
      final uri = Uri.parse(url);
      final headers = isBasic ? basicHeaderInfo() : await bearerHeaderInfo();

      if (showResult) {
        _logRequest(method, url, body);
      }

      final encodedBody = body == null ? null : jsonEncode(body);
      final response = await _send(
        method: method,
        uri: uri,
        headers: headers,
        body: encodedBody,
      ).timeout(Duration(seconds: duration));
      final apiResponse = _toGetResponse(response);

      if (showResult) {
        _logResponse(apiResponse);
      }

      await _handleResponse(apiResponse);
      return apiResponse;
    } catch (error, stackTrace) {
      return _handleException(error, stackTrace, url);
    }
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) {
    switch (method.toUpperCase()) {
      case 'GET':
        return http.get(uri, headers: headers);
      case 'POST':
        return http.post(uri, headers: headers, body: body);
      case 'PATCH':
        return http.patch(uri, headers: headers, body: body);
      case 'PUT':
        return http.put(uri, headers: headers, body: body);
      case 'DELETE':
        return http.delete(uri, headers: headers);
      default:
        throw UnsupportedError('Unsupported HTTP method: $method');
    }
  }

  Response<dynamic> _toGetResponse(http.Response response) {
    final request = response.request;

    return Response<dynamic>(
      body: _decodeBody(response.body),
      bodyString: response.body,
      request: request == null
          ? null
          : Request(
              headers: request.headers,
              method: request.method,
              url: request.url,
            ),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(body);
    } on FormatException {
      return body;
    }
  }

  Future<bool> _ensureInternet() async {
    final controller = _statusController;
    if (controller == null) {
      return true;
    }

    return controller.ensureInternet();
  }

  Future<void> _handleResponse(Response<dynamic> response) async {
    await _statusController?.handleApiResponse(response);
  }

  Response<dynamic> _handleException(
    Object error,
    StackTrace stackTrace,
    String url,
  ) {
    final failure = _failureFromException(error, stackTrace);
    log.e('API request failed: $url');
    log.e(error.toString());
    _reportError(failure);

    return _failureResponse(failure);
  }

  AppErrorInfo _failureFromException(Object error, StackTrace stackTrace) {
    if (error is TimeoutException) {
      return AppErrorInfo.timeout(error: error, stackTrace: stackTrace);
    }

    if (error is SocketException || error is http.ClientException) {
      return AppErrorInfo.noInternet();
    }

    if (error is FormatException) {
      return AppErrorInfo.badResponse(error: error, stackTrace: stackTrace);
    }

    return AppErrorInfo.unknown(error: error, stackTrace: stackTrace);
  }

  Response<dynamic> _failureResponse(AppErrorInfo error) {
    return Response<dynamic>(
      body: {'message': error.message},
      statusCode: error.statusCode ?? 400,
      statusText: error.message,
    );
  }

  Map<String, dynamic>? _bodyAsMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body;
    }

    if (body is Map) {
      return Map<String, dynamic>.from(body);
    }

    return null;
  }

  AppStatusController? get _statusController {
    if (!Get.isRegistered<AppStatusController>()) {
      return null;
    }

    return Get.find<AppStatusController>();
  }

  void _reportError(AppErrorInfo error) {
    _statusController?.reportError(error);
  }

  void _logRequest(String method, String url, Object? body) {
    log.i('[$method] $url');
    if (body != null) {
      log.i('Body: $body');
    }
  }

  void _logResponse(Response<dynamic> response) {
    log.i('Status Code: ${response.statusCode}');
    log.i('Body: ${response.bodyString}');
  }
}

class MultipartBody {
  MultipartBody(this.key, this.file);

  final String key;
  final File file;
}
