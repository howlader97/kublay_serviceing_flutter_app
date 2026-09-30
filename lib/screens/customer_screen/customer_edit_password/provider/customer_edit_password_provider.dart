import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/services/repository/auth_repository.dart';
import 'package:belwork/utils/app_log.dart';

final customerEditPasswordProvider =
    StateNotifierProvider.autoDispose<CustomerEditPasswordNotifier, bool>(
  (ref) => CustomerEditPasswordNotifier(),
);

class CustomerEditPasswordNotifier extends StateNotifier<bool> {
  CustomerEditPasswordNotifier() : super(false);

  final AuthRepository _repo = AuthRepository.instance;

  Future<bool> resetPassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = true;
    try {
      final success = await _repo.resetPassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      state = false;
      return success;
    } catch (e) {
      errorLog("CustomerEditPasswordNotifier.resetPassword", e);
      state = false;
      return false;
    }
  }
}
