import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/models/technician_job_response.dart';
import 'package:belwork/services/repository/professional_repository.dart';
import 'package:belwork/utils/app_log.dart';

class TechnicianPlannerState {
  final List<TechnicianJobItem> jobs;
  final DateTime? selectedDate;
  final bool isDateFiltered;
  final bool isLoading;
  final bool isLoadingMore;
  final int page;
  final int totalPage;
  final bool hasMore;
  final String? errorMessage;

  TechnicianPlannerState({
    this.jobs = const [],
    this.selectedDate,
    this.isDateFiltered = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.page = 1,
    this.totalPage = 1,
    this.hasMore = false,
    this.errorMessage,
  });

  TechnicianPlannerState copyWith({
    List<TechnicianJobItem>? jobs,
    DateTime? selectedDate,
    bool? isDateFiltered,
    bool? isLoading,
    bool? isLoadingMore,
    int? page,
    int? totalPage,
    bool? hasMore,
    String? errorMessage,
  }) {
    return TechnicianPlannerState(
      jobs: jobs ?? this.jobs,
      selectedDate: selectedDate ?? this.selectedDate,
      isDateFiltered: isDateFiltered ?? this.isDateFiltered,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      totalPage: totalPage ?? this.totalPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

class TechnicianPlannerNotifier extends StateNotifier<TechnicianPlannerState> {
  final ProfessionalRepository _repository = ProfessionalRepository.instance;

  TechnicianPlannerNotifier() : super(TechnicianPlannerState()) {
    fetchJobs(isRefresh: true, filterByDate: false);
  }

  String _formatDateToIso(DateTime date) {
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    return utcDate.toIso8601String();
  }

  Future<void> fetchJobs({DateTime? date, bool isRefresh = true, bool? filterByDate}) async {
    final useDateFilter = filterByDate ?? state.isDateFiltered;
    final targetDate = date ?? state.selectedDate;

    if (isRefresh) {
      state = state.copyWith(
        selectedDate: targetDate,
        isDateFiltered: useDateFilter,
        isLoading: true,
        jobs: [],
        page: 1,
        totalPage: 1,
        hasMore: false,
        errorMessage: null,
      );
    }

    try {
      final pageToFetch = isRefresh ? 1 : state.page + 1;
      final response = useDateFilter && targetDate != null
          ? await _repository.getWorkListByDate(
              dateIso: _formatDateToIso(targetDate),
              page: pageToFetch,
              limit: 10,
            )
          : await _repository.getAllJobsProfessional(
              page: pageToFetch,
              limit: 10,
            );

      if (response != null && response.data != null) {
        final newItems = response.data!;
        final pagination = response.pagination;
        final currentPage = pagination?.page ?? pageToFetch;
        final totalPages = pagination?.totalPage ?? 1;
        final hasMoreItems = currentPage < totalPages;

        final updatedJobs = isRefresh ? newItems : [...state.jobs, ...newItems];

        state = state.copyWith(
          jobs: updatedJobs,
          isLoading: false,
          isLoadingMore: false,
          page: currentPage,
          totalPage: totalPages,
          hasMore: hasMoreItems,
        );
      } else {
        state = state.copyWith(
          jobs: isRefresh ? [] : state.jobs,
          isLoading: false,
          isLoadingMore: false,
          errorMessage: 'No data found',
        );
      }
    } catch (e) {
      errorLog('TechnicianPlannerNotifier.fetchJobs', e);
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    await fetchJobs(isRefresh: false);
  }

  void selectDate(DateTime? date) {
    if (date == null) {
      clearDateFilter();
    } else {
      fetchJobs(date: date, isRefresh: true, filterByDate: true);
    }
  }

  void clearDateFilter() {
    fetchJobs(date: null, isRefresh: true, filterByDate: false);
  }
}

final technicianPlannerProvider = StateNotifierProvider<
    TechnicianPlannerNotifier, TechnicianPlannerState>(
  (ref) => TechnicianPlannerNotifier(),
);
