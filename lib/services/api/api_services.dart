import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_log.dart';
import '../../utils/app_snack_bar.dart';
import '../storage/storage_services.dart';
import 'api.dart';

class ApiServices {
  ///////////////
  ApiServices._privateConstructor();
  static final ApiServices _instance = ApiServices._privateConstructor();
  static ApiServices get instance => _instance;
  //////////  object
  final api = AppApi();
  var storageServices = StorageServices.instance;
  final appRoutes = AppRoutes.instance;

  void handleDioException(DioException e) {
    if (e.response != null) {
      if (e.response?.statusCode == 401) {
        // AppApi interceptor handles refresh token and redirects to signInScreen if unauthenticated.
        // Suppress snackbar popup so users aren't spammed with "unauthorized :no token provided".
        errorLog('api dio 401 unauthorized', e);
        return;
      }

      final data = e.response?.data;
      if (data != null) {
        String? message = extractErrorMessage(data);
        if (message != null && message.isNotEmpty) {
          AppSnackBar.instance.error(message);
          errorLog('api dio exception', e);
          return;
        }
      }

      AppSnackBar.instance.error(
        e.response?.statusMessage ??
            "Request failed with status ${e.response?.statusCode}",
      );
    } else {
      AppSnackBar.instance.error(e.message ?? "An unexpected error occurred");
    }
    errorLog('api dio exception', e);
  }

  String? extractErrorMessage(dynamic data) {
    if (data is Map) {
      final msg = data["message"] ?? data["error"] ?? data["msg"];
      if (msg != null) {
        if (msg is List && msg.isNotEmpty) {
          final first = msg.first;
          if (first is Map && first["message"] != null) {
            return first["message"].toString();
          } else if (first is Map && first["error"] != null) {
            return first["error"].toString();
          }
          return first.toString();
        } else if (msg is Map) {
          return msg["message"]?.toString() ??
              msg["error"]?.toString() ??
              msg.toString();
        }
        return msg.toString();
      }
      if (data["data"] != null) {
        return extractErrorMessage(data["data"]);
      }
    } else if (data is String &&
        data.isNotEmpty &&
        !data.contains("<!DOCTYPE")) {
      return data;
    }
    return null;
  }

  // services

  Future<dynamic> putServices({
    required String url,
    dynamic body,
    int statusCodeStart = 200,
    int statusCodeEnd = 299,
    int? statusCode,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await api.sendRequest.put(
        url,
        data: body,
        queryParameters: query,
      );
      final isSuccess = statusCode != null
          ? response.statusCode == statusCode
          : ((response.statusCode ?? 0) >= statusCodeStart &&
              (response.statusCode ?? 0) <= statusCodeEnd);
      if (isSuccess) {
        return response.data;
      } else {
        return null;
      }
    } on SocketException catch (e) {
      errorLog('api socket exception', e);
      AppSnackBar.instance.error("Check Your Internet Connection");
      return null;
    } on TimeoutException catch (e) {
      errorLog('api time out exception', e);
      return null;
    } on DioException catch (e) {
      handleDioException(e);
      return null;
    } catch (e) {
      errorLog('api exception', e);
      return null;
    }
  }

  Future<dynamic> postServices({
    required String url,
    dynamic body,
    int statusCodeStart = 200,
    int statusCodeEnd = 299,
    int? statusCode,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      Options? requestOptions = options;
      if (body is FormData) {
        requestOptions = (options ?? Options()).copyWith(contentType: null);
      } else {
        requestOptions = options;
      }

      final dynamic response = await AppApi().sendRequest.post(
        url,
        data: body,
        queryParameters: query,
        options: requestOptions,
      );
      final isSuccess = statusCode != null
          ? response.statusCode == statusCode
          : ((response.statusCode ?? 0) >= statusCodeStart &&
              (response.statusCode ?? 0) <= statusCodeEnd);
      if (isSuccess) {
        return response.data;
      } else {
        return null;
      }
    } on SocketException catch (e) {
      errorLog('api socket exception', e);
      AppSnackBar.instance.error("Check Your Internet Connection");
      return null;
    } on TimeoutException catch (e) {
      errorLog('api time out exception', e);
      return null;
    } on DioException catch (e) {
      handleDioException(e);
      return null;
    } catch (e) {
      errorLog('api exception', e);
      return null;
    }
  }

  Future<dynamic> getServices(
    String url, {
    int statusCodeStart = 200,
    int statusCodeEnd = 299,
    int? statusCode,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool showErrorSnackBar = true,
  }) async {
    try {
      final response = await api.sendRequest.get(
        url,
        queryParameters: queryParameters,
        data: body,
      );
      final isSuccess = statusCode != null
          ? response.statusCode == statusCode
          : ((response.statusCode ?? 0) >= statusCodeStart &&
              (response.statusCode ?? 0) <= statusCodeEnd);
      if (isSuccess) {
        return response.data;
      } else {
        return null;
      }
    } on SocketException catch (e) {
      errorLog('api socket exception', e);
      if (showErrorSnackBar) {
        AppSnackBar.instance.error("Check Your Internet Connection");
      }
      return null;
    } on TimeoutException catch (e) {
      errorLog('api time out exception', e);
      return null;
    } on DioException catch (e) {
      if (showErrorSnackBar) {
        handleDioException(e);
      } else {
        errorLog('api dio exception (silent)', e);
      }
      return null;
    } catch (e) {
      errorLog('api exception', e);
      return null;
    }
  }

  Future<dynamic> patchServices({
    required String url,
    Object? body,
    int statusCodeStart = 200,
    int statusCodeEnd = 299,
    int? statusCode,
    Map<String, dynamic>? query,
    Options? options,
    bool showErrorSnackBar = true,
  }) async {
    try {
      Options? requestOptions = options;
      if (body is FormData) {
        requestOptions = (options ?? Options()).copyWith(contentType: null);
      } else {
        requestOptions = options;
      }
      final response = await api.sendRequest.patch(
        url,
        data: body,
        queryParameters: query,
        options: requestOptions,
      );

      final isSuccess = statusCode != null
          ? response.statusCode == statusCode
          : ((response.statusCode ?? 0) >= statusCodeStart &&
              (response.statusCode ?? 0) <= statusCodeEnd);

      if (isSuccess) {
        return response.data;
      } else {
        if (showErrorSnackBar) {
          AppSnackBar.instance.error(
            "Unexpected response: ${response.statusCode} ${response.statusMessage}",
          );
        }
        return null;
      }
    } on SocketException catch (e) {
      errorLog('api socket exception', e);
      if (showErrorSnackBar) {
        AppSnackBar.instance.error("Check Your Internet Connection");
      }
      return null;
    } on TimeoutException catch (e) {
      errorLog('api time out exception', e);
      return null;
    } on DioException catch (e) {
      if (showErrorSnackBar) {
        handleDioException(e);
      } else {
        errorLog('api dio exception (silent)', e);
      }
      return null;
    } catch (e) {
      errorLog('api exception', e);
      return null;
    }
  }

  Future<dynamic> deleteServices({
    required String url,
    Object? body,
    int statusCodeStart = 200,
    int statusCodeEnd = 299,
    int? statusCode,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      final response = await api.sendRequest.delete(
        url,
        data: body,
        queryParameters: query,
        options: options,
      );

      final isSuccess = statusCode != null
          ? response.statusCode == statusCode
          : ((response.statusCode ?? 0) >= statusCodeStart &&
              (response.statusCode ?? 0) <= statusCodeEnd);

      if (isSuccess) {
        return response.data;
      } else {
        AppSnackBar.instance.error(
          "Unexpected response: ${response.statusCode} ${response.statusMessage}",
        );
        return null;
      }
    } on SocketException catch (e) {
      errorLog('api socket exception', e);
      AppSnackBar.instance.error("Check Your Internet Connection");
      return null;
    } on TimeoutException catch (e) {
      errorLog('api time out exception', e);
      return null;
    } on DioException catch (e) {
      handleDioException(e);
      return null;
    } catch (e) {
      errorLog('api exception', e);
      return null;
    }
  }
}
