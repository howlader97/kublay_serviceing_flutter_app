import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/company_employee_profile_model.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';

class CompanyEmployeeProfileRepository {
  CompanyEmployeeProfileRepository._privateConstructor();
  static final CompanyEmployeeProfileRepository _instance =
      CompanyEmployeeProfileRepository._privateConstructor();
  static CompanyEmployeeProfileRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  /// Fetches company employee profile details from GET /company/dashboard/employee-profile
  Future<CompanyEmployeeProfileResponse?> getEmployeeProfile() async {
    try {
      final responseData = await _apiServices.getServices(_api.employeeProfile);
      if (responseData != null && responseData is Map<String, dynamic>) {
        return CompanyEmployeeProfileResponse.fromJson(responseData);
      }
      return null;
    } catch (e) {
      errorLog('CompanyEmployeeProfileRepository.getEmployeeProfile error', e);
      return null;
    }
  }
}
