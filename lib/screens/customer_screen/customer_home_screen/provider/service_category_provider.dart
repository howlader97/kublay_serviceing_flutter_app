import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/models/service_category_response.dart';
import 'package:belwork/services/repository/service_category_repository.dart';
import 'package:belwork/utils/app_log.dart';

class ServiceCategoryNotifier
    extends StateNotifier<AsyncValue<List<ServiceCategoryModel>>> {
  final ServiceCategoryRepository _repository =
      ServiceCategoryRepository.instance;

  ServiceCategoryNotifier() : super(const AsyncValue.loading()) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.getAllServiceCategories();
      if (response != null && response.data != null) {
        state = AsyncValue.data(response.data!);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, st) {
      errorLog('ServiceCategoryNotifier.fetchCategories', e);
      state = AsyncValue.error(e, st);
    }
  }
}

final serviceCategoryProvider = StateNotifierProvider<
    ServiceCategoryNotifier, AsyncValue<List<ServiceCategoryModel>>>(
  (ref) => ServiceCategoryNotifier(),
);
