import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/models/yearly_inspection_response.dart';
import 'package:belwork/services/repository/yearly_inspection_repository.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';

class YearlyInspectionNotifier
    extends StateNotifier<AsyncValue<List<YearlyInspectionItem>>> {
  final YearlyInspectionRepository _repository =
      YearlyInspectionRepository.instance;

  YearlyInspectionNotifier() : super(const AsyncValue.data([])) {
    fetchYearlyInspections();
  }

  Future<void> fetchYearlyInspections() async {
    final token = await StorageServices.instance.getToken();
    if (token.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final response = await _repository.getYearlyInspections();
      if (response != null && response.data != null) {
        state = AsyncValue.data(response.data!);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, st) {
      errorLog('YearlyInspectionNotifier.fetchYearlyInspections', e);
      state = AsyncValue.error(e, st);
    }
  }
}

final yearlyInspectionProvider = StateNotifierProvider<
    YearlyInspectionNotifier, AsyncValue<List<YearlyInspectionItem>>>(
  (ref) => YearlyInspectionNotifier(),
);
