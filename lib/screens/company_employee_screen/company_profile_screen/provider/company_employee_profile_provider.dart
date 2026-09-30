import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/models/company_employee_profile_model.dart';
import 'package:belwork/services/repository/company_employee_profile_repository.dart';
import 'package:belwork/utils/app_log.dart';

class CompanyEmployeeProfileState {
  final CompanyEmployeeProfileResponse? profileResponse;
  final bool isLoading;
  final String? errorMessage;

  const CompanyEmployeeProfileState({
    this.profileResponse,
    this.isLoading = false,
    this.errorMessage,
  });

  CompanyEmployeeProfileState copyWith({
    CompanyEmployeeProfileResponse? profileResponse,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CompanyEmployeeProfileState(
      profileResponse: profileResponse ?? this.profileResponse,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CompanyEmployeeProfileNotifier
    extends StateNotifier<CompanyEmployeeProfileState> {
  final CompanyEmployeeProfileRepository _repository =
      CompanyEmployeeProfileRepository.instance;

  CompanyEmployeeProfileNotifier()
      : super(const CompanyEmployeeProfileState());

  Future<void> fetchProfile({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      final response = await _repository.getEmployeeProfile();
      if (response != null && response.data != null) {
        state = state.copyWith(
          profileResponse: response,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load employee profile',
        );
      }
    } catch (e) {
      errorLog('CompanyEmployeeProfileNotifier.fetchProfile error', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void clearProfile() {
    state = const CompanyEmployeeProfileState();
  }
}

final companyEmployeeProfileProvider = StateNotifierProvider.autoDispose<
    CompanyEmployeeProfileNotifier, CompanyEmployeeProfileState>(
  (ref) => CompanyEmployeeProfileNotifier(),
);
