import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/yearly_inspection_response.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';

class YearlyInspectionRepository {
  YearlyInspectionRepository._privateConstructor();
  static final YearlyInspectionRepository _instance =
      YearlyInspectionRepository._privateConstructor();
  static YearlyInspectionRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  /// Fetches yearly inspection list from GET /user/all-tasks/yearly-inspection
  Future<YearlyInspectionResponse?> getYearlyInspections() async {
    try {
      final responseData = await _apiServices.getServices(_api.yearlyInspection);
      if (responseData != null && responseData is Map<String, dynamic>) {
        return YearlyInspectionResponse.fromJson(responseData);
      }
      return null;
    } catch (e) {
      errorLog('YearlyInspectionRepository.getYearlyInspections', e);
      return null;
    }
  }
}
