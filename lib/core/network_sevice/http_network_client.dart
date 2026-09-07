import 'dart:convert';

import 'package:ZipBee_Driver/core/network_sevice/http_network_response.dart';
import 'package:ZipBee_Driver/core/services/token_refresh_service.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HttpNetworkClient {
  bool _isUnauthorized(http.Response response) {
    if (response.statusCode == 401) return true;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        if (decoded['statusCode'] == 401 ||
            decoded['error']?.toString().toLowerCase() == 'unauthorized' ||
            decoded['message']?.toString().toLowerCase().contains('invalid or expired token') == true ||
            decoded['message']?.toString().toLowerCase().contains('unauthorized') == true) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<HttpNetworkResponse> getRequest({required String url, bool isRetry = false}) async {
    final token = await SharedPreferencesHelper.getAccessToken() ?? '';
    Map<String, String> commonHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    try {
      Uri uri = Uri.parse(url);
      http.Response response = await http.get(
        uri,
        headers: commonHeaders,
      );

      if (_isUnauthorized(response) && !isRetry) {
        debugPrint('⚠️ [HttpNetworkClient] 401 on GET $url. Refreshing token...');
        final refreshed = await TokenRefreshService.refreshToken();
        if (refreshed) {
          return getRequest(url: url, isRetry: true);
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: jsonDecode(response.body),
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: response.body,
        );
      } else {
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: response.body,
        );
      }
    } on Exception catch (e) {
      return HttpNetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<HttpNetworkResponse> postRequest({
    required String url,
    required Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
    bool isRetry = false,
  }) async {
    final token = await SharedPreferencesHelper.getAccessToken() ?? '';
    Map<String, String> commonHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final header = <String, String>{};
    header.addAll(commonHeaders);
    if (extraHeaders != null) {
      header.addAll(extraHeaders);
    }
    try {
      Uri uri = Uri.parse(url);
      http.Response response = await http.post(
        uri,
        headers: header,
        body: body != null ? jsonEncode(body) : jsonEncode({}),
      );

      if (_isUnauthorized(response) && !isRetry) {
        debugPrint('⚠️ [HttpNetworkClient] 401 on POST $url. Refreshing token...');
        final refreshed = await TokenRefreshService.refreshToken();
        if (refreshed) {
          return postRequest(
            url: url,
            body: body,
            extraHeaders: extraHeaders,
            isRetry: true,
          );
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: jsonDecode(response.body),
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: response.body,
        );
      } else {
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: response.body,
        );
      }
    } on Exception catch (e) {
      return HttpNetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<HttpNetworkResponse> putRequest({
    required String url,
    required Map<String, dynamic>? body,
    bool isRetry = false,
  }) async {
    final token = await SharedPreferencesHelper.getAccessToken() ?? '';
    Map<String, String> commonHeaders = {
      'content-type': 'application/json',
      'authorization': "Bearer $token",
    };
    try {
      Uri uri = Uri.parse(url);
      http.Response response = await http.put(
        uri,
        headers: commonHeaders,
        body: jsonEncode(body),
      );

      if (_isUnauthorized(response) && !isRetry) {
        debugPrint('⚠️ [HttpNetworkClient] 401 on PUT $url. Refreshing token...');
        final refreshed = await TokenRefreshService.refreshToken();
        if (refreshed) {
          return putRequest(url: url, body: body, isRetry: true);
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseBody,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: 'Un Authorize',
        );
      } else {
        final responseBody = jsonDecode(response.body);
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: responseBody,
        );
      }
    } on Exception catch (e) {
      return HttpNetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<HttpNetworkResponse> patchRequest({
    required String url,
    required Map<String, dynamic>? body,
    bool isRetry = false,
  }) async {
    final token = await SharedPreferencesHelper.getAccessToken() ?? '';
    Map<String, String> commonHeaders = {
      'content-type': 'application/json',
      'authorization': "Bearer $token",
    };
    try {
      Uri uri = Uri.parse(url);
      http.Response response = await http.patch(
        uri,
        headers: commonHeaders,
        body: jsonEncode(body),
      );

      if (_isUnauthorized(response) && !isRetry) {
        debugPrint('⚠️ [HttpNetworkClient] 401 on PATCH $url. Refreshing token...');
        final refreshed = await TokenRefreshService.refreshToken();
        if (refreshed) {
          return patchRequest(url: url, body: body, isRetry: true);
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseBody,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: 'Un Authorize',
        );
      } else {
        final responseBody = jsonDecode(response.body);
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: responseBody,
        );
      }
    } on Exception catch (e) {
      return HttpNetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<HttpNetworkResponse> deleteRequest({required String url, bool isRetry = false}) async {
    final token = await SharedPreferencesHelper.getAccessToken() ?? '';
    Map<String, String> commonHeaders = {
      'content-type': 'application/json',
      'authorization': "Bearer $token",
    };
    try {
      Uri uri = Uri.parse(url);
      http.Response response = await http.delete(
        uri,
        headers: commonHeaders,
      );

      if (_isUnauthorized(response) && !isRetry) {
        debugPrint('⚠️ [HttpNetworkClient] 401 on DELETE $url. Refreshing token...');
        final refreshed = await TokenRefreshService.refreshToken();
        if (refreshed) {
          return deleteRequest(url: url, isRetry: true);
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseBody,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: 'Un Authorize',
        );
      } else {
        final responseBody = jsonDecode(response.body);
        return HttpNetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: responseBody,
        );
      }
    } on Exception catch (e) {
      return HttpNetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }
}

