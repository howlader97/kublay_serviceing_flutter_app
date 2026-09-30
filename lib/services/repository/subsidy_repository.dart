import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/subsidy_response.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';

class SubsidyRepository {
  SubsidyRepository._privateConstructor();
  static final SubsidyRepository _instance =
      SubsidyRepository._privateConstructor();
  static SubsidyRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  /// Fetch all regional subsidies
  /// Endpoint: GET /admin/dashboard/all-subsidies
  Future<SubsidyResponse?> getAllSubsidies({Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _apiServices.getServices(
        _api.allSubsidies,
        queryParameters: queryParams,
      );

      if (response != null && response is Map<String, dynamic>) {
        return SubsidyResponse.fromJson(response);
      }
    } catch (e) {
      errorLog("SubsidyRepository.getAllSubsidies", e);
    }
    return null;
  }
}
