import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/services/repository/delete_account_repository.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';

class DeleteAccountState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const DeleteAccountState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  DeleteAccountState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return DeleteAccountState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class DeleteAccountNotifier extends StateNotifier<DeleteAccountState> {
  final DeleteAccountRepository _repository = DeleteAccountRepository.instance;

  DeleteAccountNotifier() : super(const DeleteAccountState());

  Future<bool> deleteAccount({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      final success = await _repository.deleteProfile(
        email: email,
        password: password,
      );
      if (success) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        await StorageServices.instance.logout();
        return true;
      } else {
        state = state.copyWith(isLoading: false, isSuccess: false);
        return false;
      }
    } catch (e) {
      errorLog('DeleteAccountNotifier.deleteAccount', e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final deleteAccountProvider =
    StateNotifierProvider<DeleteAccountNotifier, DeleteAccountState>(
      (ref) => DeleteAccountNotifier(),
    );
