import 'dart:io';
import 'package:dio/dio.dart';
import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/user_profile_model.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/app_snack_bar.dart';

class UserProfileRepository {
  UserProfileRepository._privateConstructor();
  static final UserProfileRepository _instance =
      UserProfileRepository._privateConstructor();
  static UserProfileRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  Future<UserProfileModel?> getUserProfile() async {
    try {
      final response = await _apiServices.getServices(_api.userProfile);
      if (response != null) {
        return UserProfileModel.fromJson(response);
      }
    } catch (e) {
      errorLog('UserProfileRepository.getUserProfile', e);
    }
    return null;
  }

  /// Updates user profile details via PATCH /user/update-profile
  Future<dynamic> updateUserProfile({
    String? name,
    String? email,
    String? contact,
    String? address,
    String? avatarPath,
  }) async {
    try {
      final Map<String, dynamic> mapData = {};

      if (name != null && name.trim().isNotEmpty) {
        mapData['name'] = name.trim();
      }
      if (email != null && email.trim().isNotEmpty) {
        mapData['email'] = email.trim();
      }
      if (contact != null && contact.trim().isNotEmpty) {
        mapData['contact'] = contact.trim();
      }
      if (address != null && address.trim().isNotEmpty) {
        mapData['address'] = address.trim();
      }

      if (avatarPath != null &&
          avatarPath.isNotEmpty &&
          !avatarPath.startsWith('http') &&
          File(avatarPath).existsSync()) {
        final fileName = avatarPath.split('/').last.split('\\').last;
        mapData['avatar'] =
            await MultipartFile.fromFile(avatarPath, filename: fileName);
      }

      if (mapData.isEmpty) {
        AppSnackBar.instance.error("Please enter at least one detail to update");
        return null;
      }

      final formData = FormData.fromMap(mapData);

      // Call patchServices for profile update
      final response = await _apiServices.patchServices(
        url: _api.updateProfile,
        body: formData,
      );

      return response;
    } catch (e) {
      errorLog('UserProfileRepository.updateUserProfile', e);
      AppSnackBar.instance.error('Failed to update profile. Please try again.');
      return null;
    }
  }
}
