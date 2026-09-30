import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/services/repository/company_profile_edit_repository.dart';
import 'package:belwork/utils/app_log.dart';

class CompanyProfileEditState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const CompanyProfileEditState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  CompanyProfileEditState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return CompanyProfileEditState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class CompanyProfileEditNotifier
    extends StateNotifier<CompanyProfileEditState> {
  final CompanyProfileEditRepository _repository =
      CompanyProfileEditRepository.instance;

  CompanyProfileEditNotifier()
      : super(const CompanyProfileEditState());

  Future<bool> updateProfile({
    String? name,
    String? avatarPath,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      final response = await _repository.updateProfile(
        name: name,
        avatarPath: avatarPath,
      );

      if (response != null) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update profile',
          isSuccess: false,
        );
        return false;
      }
    } catch (e) {
      errorLog('CompanyProfileEditNotifier.updateProfile error', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
      return false;
    }
  }
}

final companyProfileEditProvider = StateNotifierProvider<
    CompanyProfileEditNotifier, CompanyProfileEditState>(
  (ref) => CompanyProfileEditNotifier(),
);
