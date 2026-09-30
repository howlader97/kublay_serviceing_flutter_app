import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/services/repository/technician_profile_edit_repository.dart';
import 'package:belwork/utils/app_log.dart';

class TechnicianProfileEditState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const TechnicianProfileEditState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  TechnicianProfileEditState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return TechnicianProfileEditState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class TechnicianProfileEditNotifier
    extends StateNotifier<TechnicianProfileEditState> {
  final TechnicianProfileEditRepository _repository =
      TechnicianProfileEditRepository.instance;

  TechnicianProfileEditNotifier()
      : super(const TechnicianProfileEditState());

  Future<bool> updateAccount({
    String? name,
    String? availability,
    String? workingTimeStart,
    String? workingTimeEnd,
    String? corporateVatNumber,
    String? workingRadiusKmLatitude,
    String? workingRadiusKmLongitude,
    String? workingAddress,
    String? avatarPath,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      final response = await _repository.updateAccount(
        name: name,
        availability: availability,
        workingTimeStart: workingTimeStart,
        workingTimeEnd: workingTimeEnd,
        corporateVatNumber: corporateVatNumber,
        workingRadiusKmLatitude: workingRadiusKmLatitude,
        workingRadiusKmLongitude: workingRadiusKmLongitude,
        workingAddress: workingAddress,
        avatarPath: avatarPath,
      );

      if (response != null) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update account',
          isSuccess: false,
        );
        return false;
      }
    } catch (e) {
      errorLog('TechnicianProfileEditNotifier.updateAccount error', e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
      return false;
    }
  }
}

final technicianProfileEditProvider = StateNotifierProvider<
    TechnicianProfileEditNotifier, TechnicianProfileEditState>(
  (ref) => TechnicianProfileEditNotifier(),
);
