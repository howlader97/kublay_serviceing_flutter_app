import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/models/company_service_category_response.dart';
import 'package:belwork/services/repository/company_repository.dart';
import 'package:belwork/utils/app_log.dart';

class TechnicianManageState {
  final List<CompanyServiceCategoryItem> categories;
  final bool isLoading;
  final String? errorMessage;

  const TechnicianManageState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TechnicianManageState copyWith({
    List<CompanyServiceCategoryItem>? categories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TechnicianManageState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class TechnicianManageNotifier extends StateNotifier<TechnicianManageState> {
  final CompanyRepository _repository = CompanyRepository.instance;

  TechnicianManageNotifier() : super(const TechnicianManageState());

  Future<void> fetchServiceCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _repository.getCompanyServiceCategoryList();
      if (response != null && response.data != null) {
        state = state.copyWith(categories: response.data, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to fetch company service categories',
        );
      }
    } catch (e) {
      errorLog('TechnicianManageNotifier.fetchServiceCategories', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createServiceCategory({
    required String categoryId,
    required String priorityLevel,
    required String price,
    String? avatarPath,
  }) async {
    try {
      final success = await _repository.createCompanyServiceCategory(
        categoryId: categoryId,
        priorityLevel: priorityLevel,
        price: price,
        avatarPath: avatarPath,
      );
      if (success) {
        await fetchServiceCategories();
      }
      return success;
    } catch (e) {
      errorLog('TechnicianManageNotifier.createServiceCategory', e);
      return false;
    }
  }
}

final technicianManageProvider =
    StateNotifierProvider<TechnicianManageNotifier, TechnicianManageState>(
  (ref) => TechnicianManageNotifier(),
);
