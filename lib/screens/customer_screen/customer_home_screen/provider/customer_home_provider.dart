import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/models/all_professional_response.dart';
import 'package:belwork/services/repository/customer_home_repository.dart';
import 'package:belwork/utils/app_log.dart';

// ---------- State ----------
class CustomerHomeState {
  final List<ProfessionalModel> professionals;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;

  const CustomerHomeState({
    this.professionals = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
  });

  CustomerHomeState copyWith({
    List<ProfessionalModel>? professionals,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
  }) {
    return CustomerHomeState(
      professionals: professionals ?? this.professionals,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// ---------- Notifier ----------
class CustomerHomeNotifier extends StateNotifier<CustomerHomeState> {
  final CustomerHomeRepository _repository = CustomerHomeRepository.instance;
  static const int _pageSize = 10;

  CustomerHomeNotifier() : super(const CustomerHomeState());

  /// Load first page (called on screen init)
  Future<void> fetchInitial() async {
    if (state.isLoading) return;
    state = state.copyWith(
      isLoading: true,
      professionals: [],
      currentPage: 1,
      hasMore: true,
    );
    try {
      final response = await _repository.getAllProfessionals(
        page: 1,
        limit: _pageSize,
      );
      if (response != null && response.data != null) {
        final items = response.data!.allProfessional ?? [];
        final pagination = response.data!.pagination;
        final totalPages = pagination?.totalPage ?? 1;
        state = state.copyWith(
          professionals: items,
          isLoading: false,
          currentPage: 1,
          hasMore: 1 < totalPages,
        );
      } else {
        state = state.copyWith(isLoading: false, hasMore: false);
      }
    } catch (e) {
      errorLog('CustomerHomeNotifier.fetchInitial', e);
      state = state.copyWith(isLoading: false);
    }
  }

  /// Load next page (called on scroll-to-bottom)
  Future<void> fetchMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;
    try {
      final response = await _repository.getAllProfessionals(
        page: nextPage,
        limit: _pageSize,
      );
      if (response != null && response.data != null) {
        final newItems = response.data!.allProfessional ?? [];
        final pagination = response.data!.pagination;
        final totalPages = pagination?.totalPage ?? nextPage;
        state = state.copyWith(
          professionals: [...state.professionals, ...newItems],
          isLoadingMore: false,
          currentPage: nextPage,
          hasMore: nextPage < totalPages,
        );
      } else {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
      }
    } catch (e) {
      errorLog('CustomerHomeNotifier.fetchMore', e);
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

// ---------- Provider ----------
final customerHomeProvider =
    StateNotifierProvider<CustomerHomeNotifier, CustomerHomeState>(
      (ref) => CustomerHomeNotifier(),
    );
