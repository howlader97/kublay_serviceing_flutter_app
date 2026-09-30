import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';

class JobRevisionRepository {
  JobRevisionRepository._privateConstructor();
  static final JobRevisionRepository _instance =
      JobRevisionRepository._privateConstructor();
  static JobRevisionRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  /// Submits job revision request
  /// Endpoint: POST /user/job-revision/$jobId
  Future<dynamic> submitJobRevision({
    required String jobId,
    required String note,
  }) async {
    try {
      final endpoint = _api.postJobRevision(jobId);
      final responseData = await _apiServices.postServices(
        url: endpoint,
        body: {'note': note},
      );
      return responseData;
    } catch (e) {
      errorLog('JobRevisionRepository.submitJobRevision', e);
      return null;
    }
  }
}
