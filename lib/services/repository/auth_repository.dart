import 'dart:io';
import 'package:belwork/utils/app_snack_bar.dart';
import 'package:dio/dio.dart';
import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/services/api/non_auth_api.dart';
import 'package:belwork/services/firebase_messaging_service/firebase_messaging_service.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class AuthRepository {
  ////////////// Contractures
  AuthRepository._privetContractures();
  static final AuthRepository _instance = AuthRepository._privetContractures();
  static AuthRepository get instance => _instance;

  /////////////// object
  final ApiServices apiServices = ApiServices.instance;
  NonAuthApi nonAuthApi = NonAuthApi();
  AppApiUrl api = AppApiUrl.instance;
  StorageServices storageServices = StorageServices.instance;
  /////////////// function
  Future<bool> login({
    required String email,
    required String password,
    //required String fcmToken, required String deviceId
  }) async {
    try {
      Map<String, String> bodyData = {
        "email": email.trim().toLowerCase(),
        "password": password.trim(),
        // "deviceId": deviceId.trim(),
        // "fcmToken": fcmToken.trim(),
      };

      var response = await nonAuthApi.sendRequest.post(
        api.login,
        data: bodyData,
      );

      if (response.data is Map) {
        final resData = response.data["data"] is Map
            ? response.data["data"]
            : response.data;

        final accessToken = resData["accessToken"] ?? resData["access_token"];
        if (accessToken != null && accessToken is String) {
          await storageServices.setToken(accessToken);
        }

        final refreshToken =
            resData["refreshToken"] ?? resData["refresh_token"];
        if (refreshToken != null && refreshToken is String) {
          await storageServices.setRefreshToken(refreshToken);
        }

        if (resData["user"] is Map) {
          var user = resData["user"];
          if (user["role"] is String) {
            await storageServices.setAppRoll(user["role"].toString());
          }
          if (user["id"] != null) {
            await storageServices.setUserId(user["id"].toString());
          }
        }

        if (resData["professional"] is Map) {
          var professional = resData["professional"];
          if (professional["id"] != null) {
            await storageServices.setProfessionalId(
              professional["id"].toString(),
            );
          }
        } else {
          await storageServices.clearProfessionalId();
        }

        if (resData["employee"] is Map) {
          var employee = resData["employee"];
          if (employee["id"] != null) {
            await storageServices.setEmployeeId(employee["id"].toString());
          }
        } else {
          await storageServices.clearEmployeeId();
        }

        // Sync FCM device token to backend after login
        FirebaseMessagingService.instance.syncDeviceToken(force: true);

        return true;
      }
    } on DioException catch (e) {
      apiServices.handleDioException(e);
    } catch (e) {
      errorLog("login function repo", e);
    }
    return false;
  }

  Future<bool> googleLogin({required String idToken}) async {
    try {
      Map<String, dynamic> bodyData = {"idToken": idToken.trim()};

      var response = await nonAuthApi.sendRequest.post(
        api.googleLogin,
        data: bodyData,
      );

      if (response.data is Map) {
        final resData = response.data["data"] is Map
            ? response.data["data"]
            : response.data;

        final accessToken = resData["accessToken"] ?? resData["access_token"];
        if (accessToken != null && accessToken is String) {
          await storageServices.setToken(accessToken);
        }

        final refreshToken =
            resData["refreshToken"] ?? resData["refresh_token"];
        if (refreshToken != null && refreshToken is String) {
          await storageServices.setRefreshToken(refreshToken);
        }

        if (resData["user"] is Map) {
          var user = resData["user"];
          if (user["role"] is String) {
            await storageServices.setAppRoll(user["role"].toString());
          }
          if (user["id"] != null) {
            await storageServices.setUserId(user["id"].toString());
          }
        }

        if (resData["professional"] is Map) {
          var professional = resData["professional"];
          if (professional["id"] != null) {
            await storageServices.setProfessionalId(
              professional["id"].toString(),
            );
          }
        } else {
          await storageServices.clearProfessionalId();
        }

        if (resData["employee"] is Map) {
          var employee = resData["employee"];
          if (employee["id"] != null) {
            await storageServices.setEmployeeId(employee["id"].toString());
          }
        } else {
          await storageServices.clearEmployeeId();
        }

        FirebaseMessagingService.instance.syncDeviceToken(force: true);

        return true;
      }
    } on DioException catch (e) {
      apiServices.handleDioException(e);
    } catch (e) {
      errorLog("googleLogin function repo", e);
    }
    return false;
  }

  Future<bool> appleLogin({
    required String identityToken,
    String? name,
    String? email,
  }) async {
    try {
      Map<String, dynamic> bodyData = {
        "identityToken": identityToken.trim(),
        if (name != null && name.trim().isNotEmpty) "name": name.trim(),
        if (email != null && email.trim().isNotEmpty) "email": email.trim(),
      };

      var response = await nonAuthApi.sendRequest.post(
        api.appleLogin,
        data: bodyData,
      );

      if (response.data is Map) {
        final resData = response.data["data"] is Map
            ? response.data["data"]
            : response.data;

        final accessToken = resData["accessToken"] ?? resData["access_token"];
        if (accessToken != null && accessToken is String) {
          await storageServices.setToken(accessToken);
        }

        final refreshToken =
            resData["refreshToken"] ?? resData["refresh_token"];
        if (refreshToken != null && refreshToken is String) {
          await storageServices.setRefreshToken(refreshToken);
        }

        if (resData["user"] is Map) {
          var user = resData["user"];
          if (user["role"] is String) {
            await storageServices.setAppRoll(user["role"].toString());
          }
          if (user["id"] != null) {
            await storageServices.setUserId(user["id"].toString());
          }
        }

        if (resData["professional"] is Map) {
          var professional = resData["professional"];
          if (professional["id"] != null) {
            await storageServices.setProfessionalId(
              professional["id"].toString(),
            );
          }
        } else {
          await storageServices.clearProfessionalId();
        }

        if (resData["employee"] is Map) {
          var employee = resData["employee"];
          if (employee["id"] != null) {
            await storageServices.setEmployeeId(employee["id"].toString());
          }
        } else {
          await storageServices.clearEmployeeId();
        }

        FirebaseMessagingService.instance.syncDeviceToken(force: true);

        return true;
      }
    } on DioException catch (e) {
      apiServices.handleDioException(e);
    } catch (e) {
      errorLog("appleLogin function repo", e);
    }
    return false;
  }

  /// Update FCM Device Token to backend
  /// Endpoint: POST /auth/device-token
  /// Body: { "token": "...", "deviceType": "ANDROID" | "IOS" | "WEB" }
  Future<bool> updateDeviceToken({
    required String token,
    required String deviceType,
  }) async {
    try {
      final bodyData = {"token": token.trim(), "deviceType": deviceType};

      final response = await apiServices.postServices(
        url: api.deviceToken,
        body: bodyData,
      );

      if (response != null) {
        appLog(
          "AuthRepository: Device token synced successfully ($deviceType)",
        );
        return true;
      }
    } catch (e) {
      errorLog("AuthRepository.updateDeviceToken", e);
    }
    return false;
  }

  Future<bool> accountDelete({required String password}) async {
    try {
      Map<String, String> body = {"password": password};
      var response = await apiServices.deleteServices(
        url: api.authDeleteAccount,
        body: body,
      );
      if (response != null) {
        return true;
      }
    } catch (e) {
      errorLog("accountDelete AuthRepository", e);
    }
    return false;
  }

  Future<bool> updateProfile({
    required String profileImage,
    required Map<String, String> body,
  }) async {
    try {
      FormData formData = FormData.fromMap(body);
      if (profileImage.isNotEmpty) {
        final file = File(profileImage);
        if (await file.exists()) {
          String fileName = file.path.split('/').last;
          var mimeType = lookupMimeType(file.path);
          formData.files.add(
            MapEntry(
              "profile",
              await MultipartFile.fromFile(
                file.path,
                filename: fileName,
                contentType: MediaType.parse(
                  mimeType ?? "application/octet-stream",
                ),
              ),
            ),
          );
        }
      }
      var response = await apiServices.patchServices(
        url: api.user,
        body: formData,
      );
      if (response != null) {
        return true;
      }
    } catch (e) {
      errorLog("updateProfile repo", e);
    }
    return false;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      Map<String, String> body = {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      };

      var response = await apiServices.postServices(
        url: api.changePassword,
        body: body,
      );
      if (response != null) {
        return true;
      }
    } catch (e) {
      errorLog("changePassword repo", e);
    }
    return false;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> bodyData = {
        "name": name.trim(),
        "email": email.trim().toLowerCase(),
        "password": password.trim(),
      };
      var response = await apiServices.postServices(
        url: api.user,
        body: bodyData,
      );
      if (response != null) {
        return true;
      }
    } catch (e) {
      errorLog("signUp repo", e);
    }
    return false;
  }

  Future<bool> sendOtp({required String email}) async {
    try {
      Map<String, dynamic> bodyData = {"email": email.trim().toLowerCase()};
      var response = await nonAuthApi.sendRequest.post(
        api.sendOtp,
        data: bodyData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data is Map
            ? (response.data["message"]?.toString() ??
                  "OTP sent to your email successfully")
            : "OTP sent to your email successfully";
        AppSnackBar.instance.success(message);
        await storageServices.setForgotPasswordEmail(
          email.trim().toLowerCase(),
        );
        return true;
      }
    } on DioException catch (e) {
      apiServices.handleDioException(e);
    } catch (e) {
      errorLog("sendOtp repo", e);
    }
    return false;
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    try {
      Map<String, dynamic> bodyData = {
        "otp": otp.trim(),
        "email": email.trim().toLowerCase(),
      };
      var response = await nonAuthApi.sendRequest.post(
        api.authOtpVerify,
        data: bodyData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map) {
          final resData = response.data["data"] is Map
              ? response.data["data"]
              : response.data;

          String? token;
          if (resData is Map) {
            token =
                resData["accessToken"] ??
                resData["access_token"] ??
                resData["token"];
          } else if (response.data["data"] is String) {
            token = response.data["data"];
          }

          if (token != null && token.isNotEmpty) {
            await storageServices.setToken(token);
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
      apiServices.handleDioException(e);
    } catch (e) {
      errorLog("verifyOtp repo", e);
    }
    return false;
  }

  Future<bool> updatePassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      Map<String, dynamic> bodyData = {
        "email": email.trim().toLowerCase(),
        "newPassword": newPassword.trim(),
        "confirmPassword": confirmPassword.trim(),
      };

      String token = await storageServices.getToken();

      var response = await nonAuthApi.sendRequest.post(
        api.updatePassword,
        data: bodyData,
        options: token.isNotEmpty
            ? Options(headers: {"Authorization": "Bearer $token"})
            : null,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data is Map
            ? (response.data["message"]?.toString() ??
                  "Password updated successfully")
            : "Password updated successfully";
        AppSnackBar.instance.success(message);
        await storageServices.clearForgotPasswordEmail();
        return true;
      }
    } on DioException catch (e) {
      apiServices.handleDioException(e);
    } catch (e) {
      errorLog("updatePassword repo", e);
    }
    return false;
  }

  Future<bool> authResendOTP({required String email}) async {
    try {
      var response = await apiServices.postServices(
        url: api.userResendOtp,
        body: {"email": email},
      );
      if (response != null) {
        return true;
      }
    } catch (e) {
      errorLog("authResendOTP", e);
    }
    return false;
  }

  Future<bool> authOtpVerify({
    required String email,
    required String otp,
  }) async {
    try {
      Map<String, dynamic> bodyData = {
        "otp": otp.trim(),
        "email": email.trim(),
      };
      var response = await apiServices.postServices(
        url: api.authOtpVerify,
        body: bodyData,
      );
      if (response != null) {
        final resData = response["data"] is Map ? response["data"] : response;

        final accessToken = resData["accessToken"] ?? resData["access_token"];
        if (accessToken != null && accessToken is String) {
          await storageServices.setToken(accessToken);
        }

        final refreshToken =
            resData["refreshToken"] ?? resData["refresh_token"];
        if (refreshToken != null && refreshToken is String) {
          await storageServices.setRefreshToken(refreshToken);
        }

        if (resData["user"] is Map) {
          var user = resData["user"];
          if (user["role"] is String) {
            await storageServices.setAppRoll(user["role"].toString());
          }
          if (user["id"] != null) {
            await storageServices.setUserId(user["id"].toString());
          }
        }

        if (resData["professional"] is Map) {
          var professional = resData["professional"];
          if (professional["id"] != null) {
            await storageServices.setProfessionalId(
              professional["id"].toString(),
            );
          }
        }

        if (resData["employee"] is Map) {
          var employee = resData["employee"];
          if (employee["id"] != null) {
            await storageServices.setEmployeeId(employee["id"].toString());
          }
        }

        // Sync FCM device token to backend after OTP verification
        FirebaseMessagingService.instance.syncDeviceToken(force: true);

        return true;
      }
    } catch (e) {
      errorLog("authOtpVerify", e);
    }
    return false;
  }

  ////////// forgot
  Future<bool> forgotPassword({required String email}) async {
    try {
      Map<String, String> bodyData = {"email": email};
      var response = await apiServices.postServices(
        url: api.authForgotPassword,
        body: bodyData,
      );
      if (response != null) {
        return true;
      }
    } catch (e) {
      errorLog("forgotPassword repo", e);
    }
    return false;
  }

  Future<String> forgotVerifyEmail({
    required String email,
    required int otp,
  }) async {
    try {
      Map<String, dynamic> bodyData = {"email": email, "oneTimeCode": otp};
      var response = await apiServices.postServices(
        url: api.authVerifyEmail,
        body: bodyData,
      );
      if (response != null) {
        if (response["data"] != null && response["data"] is String) {
          return response["data"].toString();
        }
      }
    } catch (e) {
      errorLog("forgotPassword repo", e);
    }
    return "";
  }

  Future<bool> forgotResetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      Map<String, dynamic> bodyData = {
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      };
      var response = await nonAuthApi.sendRequest.post(
        api.authResetPassword,
        data: bodyData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
            "Accept": "*/*",
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      }
    } on DioException catch (e) {
      apiServices.handleDioException(e);
    } catch (e) {
      errorLog("forgotPassword repo", e);
    }
    return false;
  }

  ////////// Reset / Change Password (Authenticated)
  Future<bool> resetPassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      Map<String, dynamic> bodyData = {
        "oldPassword": oldPassword.trim(),
        "newPassword": newPassword.trim(),
        "confirmPassword": confirmPassword.trim(),
      };
      var response = await apiServices.postServices(
        url: api.resetPassword,
        body: bodyData,
      );
      if (response != null) {
        final message =
            response["message"]?.toString() ?? "Password Updated !!!";
        AppSnackBar.instance.success(message);
        return true;
      }
    } catch (e) {
      errorLog("resetPassword repo", e);
    }
    return false;
  }

  ////////// Professional Auth
  Future<bool> professionalSignUp({
    required String name,
    required String email,
    required String password,
    required String corporateVatNumber,
    required String availability,
    required String categories,
    String? cbeSecurityFilePath,
  }) async {
    try {
      Map<String, dynamic> bodyData = {
        "availability": availability,
        "corporateVatNumber": corporateVatNumber,
        "name": name.trim(),
        "email": email.trim().toLowerCase(),
        "password": password.trim(),
        "categories": categories.trim(),
      };

      FormData formData = FormData.fromMap(bodyData);

      if (cbeSecurityFilePath != null && cbeSecurityFilePath.isNotEmpty) {
        final file = File(cbeSecurityFilePath);
        if (await file.exists()) {
          String fileName = file.path.split('/').last.split('\\').last;
          var mimeType = lookupMimeType(file.path);
          formData.files.add(
            MapEntry(
              "cbeSecurityFile",
              await MultipartFile.fromFile(
                file.path,
                filename: fileName,
                contentType: MediaType.parse(
                  mimeType ?? "application/octet-stream",
                ),
              ),
            ),
          );
        }
      }

      var response = await nonAuthApi.sendRequest.post(
        api.professionalAccountCreate,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } on DioException catch (e) {
      apiServices.handleDioException(e);
    } catch (e) {
      errorLog("professionalSignUp repo", e);
    }
    return false;
  }

  Future<bool> professionalOtpVerify({
    required String email,
    required String otp,
  }) async {
    try {
      Map<String, dynamic> bodyData = {
        "otp": otp.trim(),
        "email": email.trim().toLowerCase(),
      };
      var response = await nonAuthApi.sendRequest.post(
        api.professionalVerifyEmail,
        data: bodyData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data is Map
            ? (response.data["data"] is Map
                ? response.data["data"]
                : response.data)
            : null;

        if (resData != null && resData is Map) {
          final accessToken = resData["accessToken"] ??
              resData["access_token"] ??
              resData["token"];
          if (accessToken != null && accessToken is String) {
            await storageServices.setToken(accessToken);
          }

          final refreshToken =
              resData["refreshToken"] ?? resData["refresh_token"];
          if (refreshToken != null && refreshToken is String) {
            await storageServices.setRefreshToken(refreshToken);
          }

          if (resData["user"] is Map) {
            var user = resData["user"];
            if (user["role"] is String) {
              await storageServices.setAppRoll(user["role"].toString());
            }
            if (user["id"] != null) {
              await storageServices.setUserId(user["id"].toString());
            }
          }

          if (resData["professional"] is Map) {
            var professional = resData["professional"];
            if (professional["id"] != null) {
              await storageServices.setProfessionalId(
                professional["id"].toString(),
              );
            }
          }

          if (resData["employee"] is Map) {
            var employee = resData["employee"];
            if (employee["id"] != null) {
              await storageServices.setEmployeeId(employee["id"].toString());
            }
          }
        }

        return true;
      }
    } on DioException catch (e) {
      apiServices.handleDioException(e);
    } catch (e) {
      errorLog("professionalOtpVerify repo", e);
    }
    return false;
  }
}
