import 'package:belwork/services/repository/user_profile_repository.dart';
import 'package:belwork/utils/app_log.dart';

class CompanyProfileEditRepository {
  CompanyProfileEditRepository._privateConstructor();
  static final CompanyProfileEditRepository _instance =
      CompanyProfileEditRepository._privateConstructor();
  static CompanyProfileEditRepository get instance => _instance;

  final UserProfileRepository _userProfileRepository = UserProfileRepository.instance;

  /// Updates company employee name and avatar via PATCH /user/update-profile
  Future<dynamic> updateProfile({
    String? name,
    String? avatarPath,
  }) async {
    try {
      final response = await _userProfileRepository.updateUserProfile(
        name: name,
        avatarPath: avatarPath,
      );
      return response;
    } catch (e) {
      errorLog('CompanyProfileEditRepository.updateProfile error', e);
      return null;
    }
  }
}
