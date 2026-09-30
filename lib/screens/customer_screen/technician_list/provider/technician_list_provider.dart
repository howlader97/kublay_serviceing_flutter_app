import 'package:belwork/models/professional_by_category_response.dart';
import 'package:belwork/services/repository/customer_home_repository.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:flutter_riverpod/legacy.dart';

class TechnicianListState {
  final bool isLoading;
  final List<ProfessionalByCategoryItem> professionals;
  final List<ProfessionalByCategoryItem> filteredProfessionals;
  final String searchQuery;
  final String? errorMessage;

  const TechnicianListState({
    this.isLoading = false,
    this.professionals = const [],
    this.filteredProfessionals = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  TechnicianListState copyWith({
    bool? isLoading,
    List<ProfessionalByCategoryItem>? professionals,
    List<ProfessionalByCategoryItem>? filteredProfessionals,
    String? searchQuery,
    String? errorMessage,
  }) {
    return TechnicianListState(
      isLoading: isLoading ?? this.isLoading,
      professionals: professionals ?? this.professionals,
      filteredProfessionals:
          filteredProfessionals ?? this.filteredProfessionals,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class TechnicianListNotifier extends StateNotifier<TechnicianListState> {
  final CustomerHomeRepository _repository = CustomerHomeRepository.instance;

  TechnicianListNotifier() : super(const TechnicianListState());

  Future<void> fetchProfessionals(String? categoryId) async {
    if (categoryId == null || categoryId.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        professionals: [],
        filteredProfessionals: [],
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      professionals: [],
      filteredProfessionals: [],
      errorMessage: null,
    );

    try {
      final response = await _repository.getProfessionalsByCategory(
        categoryId: categoryId,
      );

      final rawList = response?.data?.allProfessional ?? [];
      // Client-side category matching filter:
      final list = rawList.where((prof) {
        if (prof.categories == null || prof.categories!.isEmpty) return false;
        return prof.categories!.contains(categoryId);
      }).toList();

      state = state.copyWith(
        isLoading: false,
        professionals: list,
        filteredProfessionals: _applyFilter(list, state.searchQuery),
      );
    } catch (e) {
      errorLog('TechnicianListNotifier.fetchProfessionals', e);
      state = state.copyWith(
        isLoading: false,
        professionals: [],
        filteredProfessionals: [],
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> fetchNearestProfessionals({
    required String lat,
    required String lng,
    required String radiusKm,
    required String category,
  }) async {
    state = state.copyWith(
      isLoading: true,
      professionals: [],
      filteredProfessionals: [],
      errorMessage: null,
    );

    try {
      final rawList = await _repository.getNearestProfessionalsByCategory(
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        category: category,
      );

      final list = category.isNotEmpty
          ? rawList.where((prof) {
              if (prof.categories == null || prof.categories!.isEmpty) return false;
              return prof.categories!.contains(category);
            }).toList()
          : rawList;

      state = state.copyWith(
        isLoading: false,
        professionals: list,
        filteredProfessionals: _applyFilter(list, state.searchQuery),
      );
    } catch (e) {
      errorLog('TechnicianListNotifier.fetchNearestProfessionals', e);
      state = state.copyWith(
        isLoading: false,
        professionals: [],
        filteredProfessionals: [],
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredProfessionals: _applyFilter(state.professionals, query),
    );
  }

  List<ProfessionalByCategoryItem> _applyFilter(
    List<ProfessionalByCategoryItem> list,
    String query,
  ) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return list;

    return list.where((item) {
      final name = item.user?.name?.toLowerCase() ?? '';
      final type = item.type?.toLowerCase() ?? '';
      final email = item.user?.email?.toLowerCase() ?? '';
      return name.contains(trimmed) ||
          type.contains(trimmed) ||
          email.contains(trimmed);
    }).toList();
  }
}

final technicianListProvider =
    StateNotifierProvider.autoDispose<
      TechnicianListNotifier,
      TechnicianListState
    >((ref) {
      return TechnicianListNotifier();
    });
