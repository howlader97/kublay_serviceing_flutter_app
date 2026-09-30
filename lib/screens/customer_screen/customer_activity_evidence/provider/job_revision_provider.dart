import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/services/repository/job_revision_repository.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/app_snack_bar.dart';

class JobRevisionNotifier extends StateNotifier<AsyncValue<dynamic>> {
  final JobRevisionRepository _repository = JobRevisionRepository.instance;

  JobRevisionNotifier() : super(const AsyncValue.data(null));

  Future<bool> submitRevision({
    required String jobId,
    required String note,
  }) async {
    if (jobId.isEmpty) {
      AppSnackBar.instance.error("Invalid Job ID");
      return false;
    }
    if (note.isEmpty) {
      AppSnackBar.instance.error("Please enter a revision note");
      return false;
    }

    state = const AsyncValue.loading();
    try {
      final response = await _repository.submitJobRevision(
        jobId: jobId,
        note: note,
      );

      if (response != null) {
        state = AsyncValue.data(response);
        AppSnackBar.instance.success("Revision requested successfully!");
        return true;
      } else {
        state = const AsyncValue.data(null);
        return false;
      }
    } catch (e, st) {
      errorLog('JobRevisionNotifier.submitRevision', e);
      state = AsyncValue.error(e, st);
      AppSnackBar.instance.error("Failed to request revision");
      return false;
    }
  }
}

final jobRevisionProvider =
    StateNotifierProvider<JobRevisionNotifier, AsyncValue<dynamic>>(
  (ref) => JobRevisionNotifier(),
);
