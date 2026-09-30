import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/models/task_evidence_response.dart';
import 'package:belwork/services/repository/task_evidence_repository.dart';
import 'package:belwork/utils/app_log.dart';

class CustomerEvidenceNotifier
    extends StateNotifier<AsyncValue<List<TaskEvidenceItem>>> {
  final TaskEvidenceRepository _repository = TaskEvidenceRepository.instance;
  final String jobId;

  CustomerEvidenceNotifier(this.jobId) : super(const AsyncValue.loading()) {
    fetchEvidences();
  }

  Future<void> fetchEvidences() async {
    state = const AsyncValue.loading();
    try {
      if (jobId.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }
      final response = await _repository.getTaskEvidenceByJobId(jobId);
      if (response != null && response.data != null) {
        final list = response.data!.allTask ?? [];
        // Sort by date and time: latest at the top (createdAt descending)
        list.sort((a, b) {
          final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return dateB.compareTo(dateA);
        });
        state = AsyncValue.data(list);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, st) {
      errorLog('CustomerEvidenceNotifier.fetchEvidences', e);
      state = AsyncValue.error(e, st);
    }
  }
}

final customerEvidenceProvider = StateNotifierProvider.family<
    CustomerEvidenceNotifier, AsyncValue<List<TaskEvidenceItem>>, String>(
  (ref, jobId) => CustomerEvidenceNotifier(jobId),
);
