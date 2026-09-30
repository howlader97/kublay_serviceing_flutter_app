import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/employee_assigned_sites_model.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';

class CompanyAgendaRepository {
  CompanyAgendaRepository._privateConstructor();
  static final CompanyAgendaRepository _instance =
      CompanyAgendaRepository._privateConstructor();
  static CompanyAgendaRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  /// Fetches assigned sites for employee from GET /company/assigned/all-assigned-sites-by-employee/{employeeId}
  Future<EmployeeAssignedSitesResponse?> getCompanyAgendaJobs(String employeeId) async {
    try {
      final url = _api.employeeAllJob(employeeId);
      final responseData = await _apiServices.getServices(url);
      if (responseData != null && responseData is Map<String, dynamic>) {
        return EmployeeAssignedSitesResponse.fromJson(responseData);
      }
      return null;
    } catch (e) {
      errorLog('CompanyAgendaRepository.getCompanyAgendaJobs error', e);
      return null;
    }
  }
}
