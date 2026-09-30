import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/models/subsidy_response.dart';
import 'package:belwork/services/repository/subsidy_repository.dart';
import 'package:belwork/utils/app_log.dart';

class SubsidyNotifier extends StateNotifier<AsyncValue<List<SubsidyItem>>> {
  final SubsidyRepository _repository = SubsidyRepository.instance;
  List<SubsidyItem> _allSubsidies = [];

  SubsidyNotifier() : super(const AsyncValue.loading()) {
    fetchSubsidies();
  }

  List<SubsidyItem> get allSubsidies => _allSubsidies;

  Future<void> fetchSubsidies({Map<String, dynamic>? queryParams}) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.getAllSubsidies(queryParams: queryParams);
      if (response != null && response.data != null && response.data?.allSubsidyLists != null) {
        _allSubsidies = response.data!.allSubsidyLists!;
        state = AsyncValue.data(_allSubsidies);
      } else {
        _allSubsidies = [];
        state = const AsyncValue.data([]);
      }
    } catch (e, st) {
      errorLog('SubsidyNotifier.fetchSubsidies', e);
      state = AsyncValue.error(e, st);
    }
  }

  void filterSubsidies({String? region, String? query}) {
    List<SubsidyItem> filtered = List.from(_allSubsidies);

    if (region != null && region.isNotEmpty && region.toUpperCase() != 'ALL') {
      filtered = filtered.where((item) {
        return (item.region ?? '').toUpperCase() == region.toUpperCase();
      }).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      filtered = filtered.where((item) {
        final title = (item.title ?? '').toLowerCase();
        final description = (item.description ?? '').toLowerCase();
        final reg = (item.region ?? '').toLowerCase();
        return title.contains(q) || description.contains(q) || reg.contains(q);
      }).toList();
    }

    state = AsyncValue.data(filtered);
  }
}

final subsidyProvider = StateNotifierProvider<SubsidyNotifier, AsyncValue<List<SubsidyItem>>>(
  (ref) => SubsidyNotifier(),
);
