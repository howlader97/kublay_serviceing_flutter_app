import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/services/repository/job_feedback_repository.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/app_snack_bar.dart';

class JobFeedbackNotifier extends StateNotifier<AsyncValue<dynamic>> {
  final JobFeedbackRepository _repository = JobFeedbackRepository.instance;

  JobFeedbackNotifier() : super(const AsyncValue.data(null));

  Future<bool> submitFeedback({
    required String jobId,
    required int rating,
    required String userId,
    required String professionalId,
    required String note,
  }) async {
    if (rating <= 0) {
      AppSnackBar.instance.error("Please select a rating star");
      return false;
    }
    if (jobId.isEmpty) {
      AppSnackBar.instance.error("Invalid Job ID");
      return false;
    }

    state = const AsyncValue.loading();
    try {
      final response = await _repository.submitJobFeedback(
        jobId: jobId,
        rating: rating.toString(),
        userId: userId,
        professionalId: professionalId,
        note: note,
      );

      if (response != null) {
        state = AsyncValue.data(response);
        AppSnackBar.instance.success("Feedback submitted successfully!");
        return true;
      } else {
        state = const AsyncValue.data(null);
        return false;
      }
    } catch (e, st) {
      errorLog('JobFeedbackNotifier.submitFeedback', e);
      state = AsyncValue.error(e, st);
      AppSnackBar.instance.error("Failed to submit feedback");
      return false;
    }
  }
}

final jobFeedbackProvider =
    StateNotifierProvider<JobFeedbackNotifier, AsyncValue<dynamic>>(
  (ref) => JobFeedbackNotifier(),
);
