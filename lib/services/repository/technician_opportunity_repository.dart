import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/technician_job_response.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';

class TechnicianOpportunityRepository {
  TechnicianOpportunityRepository._privateConstructor();
  static final TechnicianOpportunityRepository _instance =
      TechnicianOpportunityRepository._privateConstructor();
  static TechnicianOpportunityRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  /// Fetches all technician opportunity jobs from GET /user/all-job-list
  Future<TechnicianJobResponse?> getTechnicianJobs([String? userId]) async {
    try {
      final responseData =
          await _apiServices.getServices(_api.allJobList);
      if (responseData != null && responseData is Map<String, dynamic>) {
        return TechnicianJobResponse.fromJson(responseData);
      }
      return null;
    } catch (e) {
      errorLog('TechnicianOpportunityRepository.getTechnicianJobs', e);
      return null;
    }
  }
}
