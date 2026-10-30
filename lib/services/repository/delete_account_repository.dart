import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/app_snack_bar.dart';

class DeleteAccountRepository {
  DeleteAccountRepository._privateConstructor();
  static final DeleteAccountRepository _instance =
      DeleteAccountRepository._privateConstructor();
  static DeleteAccountRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  Future<bool> deleteProfile({
    required String email,
    required String password,
  }) async {
    try {
      final body = {
        "email": email,
        "password": password,
      };

      final responseData = await _apiServices.deleteServices(
        url: _api.deleteProfile,
        body: body,
      );

      if (responseData != null) {
        if (responseData is Map && responseData['message'] != null) {
          AppSnackBar.instance.success(responseData['message'].toString());
        } else {
          AppSnackBar.instance.success("Account deleted successfully.");
        }
        return true;
      }
      return false;
    } catch (e) {
      errorLog('DeleteAccountRepository.deleteProfile', e);
      return false;
    }
  }
}
