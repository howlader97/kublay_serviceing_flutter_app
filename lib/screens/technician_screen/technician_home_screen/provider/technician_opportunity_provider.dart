import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/models/technician_job_response.dart';
import 'package:belwork/services/repository/technician_opportunity_repository.dart';
import 'package:belwork/utils/app_log.dart';

class TechnicianOpportunityNotifier
    extends StateNotifier<AsyncValue<List<TechnicianJobItem>>> {
  final TechnicianOpportunityRepository _repository =
      TechnicianOpportunityRepository.instance;

  TechnicianOpportunityNotifier() : super(const AsyncValue.loading()) {
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.getTechnicianJobs();
      if (response != null && response.data != null) {
        state = AsyncValue.data(response.data!);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, st) {
      errorLog('TechnicianOpportunityNotifier.fetchJobs', e);
      state = AsyncValue.error(e, st);
    }
  }
}

final technicianOpportunityProvider = StateNotifierProvider<
    TechnicianOpportunityNotifier, AsyncValue<List<TechnicianJobItem>>>(
  (ref) {
    return TechnicianOpportunityNotifier();
  },
);
