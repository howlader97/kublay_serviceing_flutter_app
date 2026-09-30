import 'package:dio/dio.dart';
import 'package:belwork/constant/app_api_url.dart';
import 'package:belwork/services/api/api_services.dart';
import 'package:belwork/utils/app_log.dart';

class JobFeedbackRepository {
  JobFeedbackRepository._privateConstructor();
  static final JobFeedbackRepository _instance =
      JobFeedbackRepository._privateConstructor();
  static JobFeedbackRepository get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final AppApiUrl _api = AppApiUrl.instance;

  /// Submits feedback for a completed job
  /// Endpoint: POST /user/jobs/$jobId/feedback
  Future<dynamic> submitJobFeedback({
    required String jobId,
    required String rating,
    required String userId,
    required String professionalId,
    required String note,
  }) async {
    try {
      final formData = FormData.fromMap({
        'jobId': jobId,
        'rating': rating,
        'userId': userId,
        'professionalId': professionalId,
        'note': note,
      });

      final endpoint = _api.postJobFeedback(jobId);
      final responseData = await _apiServices.postServices(
        url: endpoint,
        body: formData,
      );
      return responseData;
    } catch (e) {
      errorLog('JobFeedbackRepository.submitJobFeedback', e);
      return null;
    }
  }
}
