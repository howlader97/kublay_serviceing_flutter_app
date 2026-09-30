import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/models/employee_assigned_sites_model.dart';
import 'package:belwork/models/technician_job_response.dart';
import 'package:belwork/services/repository/company_agenda_repository.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';

class CompanyAgendaState {
  final List<EmployeeAssignedSiteItem> assignedSites;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? selectedDate;
  final String selectedStatusFilter; // 'ALL', 'PENDING', 'IN_PROGRESS', 'FINISHED', 'DISPUTED'

  const CompanyAgendaState({
    this.assignedSites = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedDate,
    this.selectedStatusFilter = 'ALL',
  });

  CompanyAgendaState copyWith({
    List<EmployeeAssignedSiteItem>? assignedSites,
    bool? isLoading,
    String? errorMessage,
    DateTime? selectedDate,
    String? selectedStatusFilter,
  }) {
    return CompanyAgendaState(
      assignedSites: assignedSites ?? this.assignedSites,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
    );
  }

  List<TechnicianJobItem> get allJobs {
    return assignedSites.map((site) => site.effectiveJob).toList();
  }

  List<TechnicianJobItem> get pendingJobs {
    return assignedSites
        .where((site) {
          final s1 = (site.job?.status ?? '')
              .toUpperCase()
              .replaceAll('_', '')
              .replaceAll(' ', '')
              .replaceAll('-', '');
          final s2 = (site.status ?? '')
              .toUpperCase()
              .replaceAll('_', '')
              .replaceAll(' ', '')
              .replaceAll('-', '');
          final combined = '$s1 $s2';
          return combined.contains('PENDING') ||
              combined.contains('NEW') ||
              combined.contains('ASSIGN');
        })
        .map((site) => site.effectiveJob)
        .toList();
  }

  List<TechnicianJobItem> get inProgressJobs {
    return assignedSites
        .where((site) {
          final s1 = (site.job?.status ?? '')
              .toUpperCase()
              .replaceAll('_', '')
              .replaceAll(' ', '')
              .replaceAll('-', '');
          final s2 = (site.status ?? '')
              .toUpperCase()
              .replaceAll('_', '')
              .replaceAll(' ', '')
              .replaceAll('-', '');
          final combined = '$s1 $s2';
          return combined.contains('PROGRESS') ||
              combined.contains('PROCESS') ||
              combined.contains('WORKING') ||
              combined.contains('ACTIVE') ||
              combined.contains('START') ||
              combined.contains('RUNNING') ||
              combined.contains('ONGOING') ||
              s1 == 'INPROGRESS' ||
              s2 == 'INPROGRESS' ||
              s1 == 'INPROCESS' ||
              s2 == 'INPROCESS';
        })
        .map((site) => site.effectiveJob)
        .toList();
  }

  List<TechnicianJobItem> get finishedJobs {
    return assignedSites
        .where((site) {
          final s1 = (site.job?.status ?? '')
              .toUpperCase()
              .replaceAll('_', '')
              .replaceAll(' ', '')
              .replaceAll('-', '');
          final s2 = (site.status ?? '')
              .toUpperCase()
              .replaceAll('_', '')
              .replaceAll(' ', '')
              .replaceAll('-', '');
          final combined = '$s1 $s2';
          return combined.contains('FINISH') ||
              combined.contains('COMPLETE') ||
              combined.contains('DONE');
        })
        .map((site) => site.effectiveJob)
        .toList();
  }

  List<TechnicianJobItem> get disputedJobs {
    return assignedSites
        .where((site) {
          final s1 = (site.job?.status ?? '').toUpperCase();
          final s2 = (site.status ?? '').toUpperCase();
          return s1.contains('DISPUTE') || s2.contains('DISPUTE');
        })
        .map((site) => site.effectiveJob)
        .toList();
  }
}

class CompanyAgendaNotifier extends StateNotifier<CompanyAgendaState> {
  final CompanyAgendaRepository _repository = CompanyAgendaRepository.instance;
  final StorageServices _storageServices = StorageServices.instance;

  CompanyAgendaNotifier() : super(const CompanyAgendaState());

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setStatusFilter(String status) {
    state = state.copyWith(selectedStatusFilter: status);
  }

  Future<void> fetchJobs({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      var employeeId = await _storageServices.getEmployeeId();
      if (employeeId.isEmpty) {
        employeeId = await _storageServices.getProfessionalId();
      }

      if (employeeId.isEmpty) {
        errorLog('CompanyAgendaNotifier', 'Employee ID is empty');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Employee ID is missing',
        );
        return;
      }

      final response = await _repository.getCompanyAgendaJobs(employeeId);
      if (response != null && response.data != null) {
        state = state.copyWith(
          assignedSites: response.data!,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          assignedSites: [],
          isLoading: false,
        );
      }
    } catch (e) {
      errorLog('CompanyAgendaNotifier.fetchJobs error', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final companyAgendaProvider =
    StateNotifierProvider<CompanyAgendaNotifier, CompanyAgendaState>(
  (ref) => CompanyAgendaNotifier(),
);
