import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/services/api/non_auth_api.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../storage/storage_services.dart';

class AppApi {
  final Dio _dio = Dio();
  static Completer<String?>? _refreshCompleter;

  AppApi._privateConstructor() {
    _dio.options.baseUrl = AppApiUrl.instance.baseUrl;
    _dio.options.sendTimeout = const Duration(seconds: 120);
    _dio.options.connectTimeout = const Duration(seconds: 120);
    _dio.options.receiveTimeout = const Duration(seconds: 120);
    _dio.options.followRedirects = false;

    _dio.interceptors.addAll({
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.baseUrl = AppApiUrl.instance.baseUrl;
          if (options.data is! FormData) {
            options.contentType = 'application/json';
          } else {
            options.contentType = null;
          }
          options.headers["Accept"] = "application/json";

          String token = await storageServices.getToken();
          if (token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options); // Continue request
        },

        onError: (error, handler) async {
          appLog("""
API error occurred:
Status code: ${error.response?.statusCode}
Path: ${error.requestOptions.path}
Error message: ${error.message}
""");

          try {
            if (error.response?.statusCode == 401) {
              final path = error.requestOptions.path.toLowerCase();
              // Do not try to refresh if the request was already to a login or refresh endpoint
              if (path.contains("refresh") || path.contains("login")) {
                await storageServices.logout();
                appRoutes.go(AppRoutesKey.instance.signInScreen);
                return handler.next(error);
              }

              // 1. If another request is currently refreshing the token, wait for it
              if (_refreshCompleter != null) {
                final newToken = await _refreshCompleter!.future;
                if (newToken != null && newToken.isNotEmpty) {
                  final opts = error.requestOptions;
                  opts.headers["Authorization"] = "Bearer $newToken";
                  try {
                    final response = await _dio.fetch(opts);
                    return handler.resolve(response);
                  } catch (retryError) {
                    return handler.next(error);
                  }
                } else {
                  return handler.next(error);
                }
              }

              // 2. Start new refresh operation
              _refreshCompleter = Completer<String?>();
              final refreshToken = await storageServices.getRefreshToken();

              if (refreshToken.trim().isEmpty) {
                _refreshCompleter!.complete(null);
                _refreshCompleter = null;
                await storageServices.logout();
                appRoutes.go(AppRoutesKey.instance.signInScreen);
                return handler.next(error);
              }

              final newAccessToken = await reFreshNewAccessToken(refreshToken);

              if (newAccessToken.isNotEmpty) {
                _refreshCompleter!.complete(newAccessToken);
                _refreshCompleter = null;

                // Update default header on Dio instance
                _dio.options.headers["Authorization"] = "Bearer $newAccessToken";

                // Update the failed request header and retry
                final opts = error.requestOptions;
                opts.headers["Authorization"] = "Bearer $newAccessToken";
                try {
                  final response = await _dio.fetch(opts);
                  return handler.resolve(response);
                } catch (retryError) {
                  return handler.next(error);
                }
              } else {
                _refreshCompleter!.complete(null);
                _refreshCompleter = null;

                await storageServices.logout();
                appRoutes.go(AppRoutesKey.instance.signInScreen);
                return handler.next(error);
              }
            }
          } catch (e) {
            if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
              _refreshCompleter!.complete(null);
            }
            _refreshCompleter = null;
            errorLog("Error during 401 token refresh", e);
            await storageServices.logout();
            appRoutes.go(AppRoutesKey.instance.signInScreen);
            return handler.next(error);
          }

          return handler.next(error); // Continue with error
        },
      ),
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          request: true,
          compact: true,
          error: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
        ),

    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static final AppApi _instance = AppApi._privateConstructor();

  factory AppApi() => _instance;

  static AppApi get instance => _instance;
  var storageServices = StorageServices.instance;
  final appRoutes = AppRoutes.instance;

  Dio get sendRequest => _dio;
}

/// Token refresh logic with fallback endpoints, headers, cookies, and resilient parsing
Future<String> reFreshNewAccessToken(String refreshToken) async {
  if (refreshToken.trim().isEmpty) return "";
  try {
    final cleanRefreshToken = refreshToken.trim();
    final endpoints = [
      AppApiUrl.instance.refreshToken, // "/auth/reset-refresh-token"
      "/auth/reset-refresh-token",
      "/auth/refresh-token",
      "/auth/refreshToken",
      "/refreshToken",
    ];

    final uniqueEndpoints = endpoints.toSet().toList();

    for (final endpoint in uniqueEndpoints) {
      try {
        final response = await NonAuthApi().sendRequest.post(
          endpoint,
          data: {
            "refreshToken": cleanRefreshToken,
            "token": cleanRefreshToken,
          },
          options: Options(
            headers: {
              "Authorization": "Bearer $cleanRefreshToken",
              "refreshToken": cleanRefreshToken,
              "Cookie": "refreshToken=$cleanRefreshToken; accessToken=$cleanRefreshToken",
            },
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final dynamic data = response.data;
          final resData = data is Map
              ? (data["data"] is Map ? data["data"] : data)
              : null;

          String? newAccessToken;
          String? newRefreshToken;

          if (resData != null && resData is Map) {
            newAccessToken = resData["accessToken"]?.toString() ??
                resData["access_token"]?.toString() ??
                resData["token"]?.toString();
            newRefreshToken = resData["refreshToken"]?.toString() ??
                resData["refresh_token"]?.toString();
          } else if (data is String && data.isNotEmpty && !data.startsWith("<")) {
            newAccessToken = data;
          }

          // Also check Set-Cookie headers for new tokens if returned via cookie
          final setCookieHeaders = response.headers["set-cookie"];
          if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
            for (final cookie in setCookieHeaders) {
              if (newAccessToken == null || newAccessToken.isEmpty) {
                final match = RegExp(r'accessToken=([^;]+)').firstMatch(cookie);
                if (match != null) {
                  newAccessToken = match.group(1);
                }
              }
              if (newRefreshToken == null || newRefreshToken.isEmpty) {
                final match = RegExp(r'refreshToken=([^;]+)').firstMatch(cookie);
                if (match != null) {
                  newRefreshToken = match.group(1);
                }
              }
            }
          }

          if (newAccessToken != null &&
              newAccessToken.isNotEmpty &&
              newAccessToken != "null") {
            await StorageServices.instance.setToken(newAccessToken);
            if (newRefreshToken != null &&
                newRefreshToken.isNotEmpty &&
                newRefreshToken != "null") {
              await StorageServices.instance.setRefreshToken(newRefreshToken);
            }
            appLog("Successfully refreshed access token from $endpoint");
            return newAccessToken;
          }
        }
      } catch (endpointError) {
        errorLog("reFreshNewAccessToken attempt at $endpoint failed", endpointError);
      }
    }
  } catch (e) {
    errorLog("reFreshNewAccessToken overall failure", e);
  }
  return "";
}
