import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/models/task_evidence_response.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';

class TaskEvidenceRepository {
  TaskEvidenceRepository._privateConstructor();
  static final TaskEvidenceRepository _instance =
      TaskEvidenceRepository._privateConstructor();
  static TaskEvidenceRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  /// Fetches task evidence list by jobId
  /// Endpoint: GET /professional/all-task-evidence-by-user/$jobId
  Future<TaskEvidenceResponse?> getTaskEvidenceByJobId(String jobId) async {
    try {
      final endpoint = _api.allTaskEvidenceByUser(jobId);
      final responseData = await _apiServices.getServices(endpoint);
      if (responseData != null && responseData is Map<String, dynamic>) {
        return TaskEvidenceResponse.fromJson(responseData);
      }
      return null;
    } catch (e) {
      errorLog('TaskEvidenceRepository.getTaskEvidenceByJobId', e);
      return null;
    }
  }
}
