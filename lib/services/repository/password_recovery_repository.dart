import 'package:dio/dio.dart';
import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/services/api/non_auth_api.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/app_snack_bar.dart';

class PasswordRecoveryRepository {
  PasswordRecoveryRepository._privateConstructor();
  static final PasswordRecoveryRepository _instance =
      PasswordRecoveryRepository._privateConstructor();
  static PasswordRecoveryRepository get instance => _instance;

  final NonAuthApi _nonAuthApi = NonAuthApi();
  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;
  final StorageServices _storageServices = StorageServices.instance;

  /// Send OTP to user's email for password recovery
  /// Endpoint: POST /auth/send-otp
  /// Body: { "email": "..." }
  Future<bool> sendOtp({required String email}) async {
    try {
      final Map<String, dynamic> bodyData = {
        "email": email.trim().toLowerCase(),
      };

      final response = await _nonAuthApi.sendRequest.post(
        _api.sendOtp,
        data: bodyData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data is Map
            ? (response.data["message"]?.toString() ??
                "OTP sent to your email successfully")
            : "OTP sent to your email successfully";
        AppSnackBar.instance.success(message);
        await _storageServices.setForgotPasswordEmail(email.trim().toLowerCase());
        return true;
      }
    } on DioException catch (e) {
      _apiServices.handleDioException(e);
    } catch (e) {
      errorLog("PasswordRecoveryRepository.sendOtp", e);
    }
    return false;
  }

  /// Verify OTP code sent to user's email
  /// Endpoint: POST /auth/verify-opt
  /// Body: { "otp": "...", "email": "..." }
  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final Map<String, dynamic> bodyData = {
        "otp": otp.trim(),
        "email": email.trim().toLowerCase(),
      };

      final response = await _nonAuthApi.sendRequest.post(
        _api.authOtpVerify,
        data: bodyData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map) {
          final resData = response.data["data"] is Map
              ? response.data["data"]
              : response.data;

          String? token;
          if (resData is Map) {
            token = resData["accessToken"] ??
                resData["access_token"] ??
                resData["token"];
          } else if (response.data["data"] is String) {
            token = response.data["data"];
          }

          if (token != null && token.isNotEmpty) {
            await _storageServices.setToken(token);
          }
        }

        final message = response.data is Map
            ? (response.data["message"]?.toString() ??
                "OTP verified successfully")
            : "OTP verified successfully";
        AppSnackBar.instance.success(message);
        return true;
      }
    } on DioException catch (e) {
      _apiServices.handleDioException(e);
    } catch (e) {
      errorLog("PasswordRecoveryRepository.verifyOtp", e);
    }
    return false;
  }

  /// Update password with Bearer Token from OTP verification
  /// Endpoint: POST /auth/update-password
  /// Body: { "email": "...", "newPassword": "...", "confirmPassword": "..." }
  Future<bool> updatePassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final Map<String, dynamic> bodyData = {
        "email": email.trim().toLowerCase(),
        "newPassword": newPassword.trim(),
        "confirmPassword": confirmPassword.trim(),
      };

      final token = await _storageServices.getToken();

      final response = await _nonAuthApi.sendRequest.post(
        _api.updatePassword,
        data: bodyData,
        options: token.isNotEmpty
            ? Options(
                headers: {
                  "Authorization": "Bearer $token",
                },
              )
            : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data is Map
            ? (response.data["message"]?.toString() ??
                "Password updated successfully")
            : "Password updated successfully";
        AppSnackBar.instance.success(message);
        await _storageServices.clearForgotPasswordEmail();
        return true;
      }
    } on DioException catch (e) {
      _apiServices.handleDioException(e);
    } catch (e) {
      errorLog("PasswordRecoveryRepository.updatePassword", e);
    }
    return false;
  }
}
