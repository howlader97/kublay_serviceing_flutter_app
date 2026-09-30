import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/services/repository/password_recovery_repository.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';

final resetPasswordProvider =
    StateNotifierProvider<ResetPasswordNotifier, AsyncValue<bool>>((ref) {
  return ResetPasswordNotifier();
});

class ResetPasswordNotifier extends StateNotifier<AsyncValue<bool>> {
  ResetPasswordNotifier() : super(const AsyncValue.data(false));

  Future<bool> updatePassword({
    required String newPassword,
    required String confirmPassword,
    String? email,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userEmail = email ?? await StorageServices.instance.getForgotPasswordEmail();
      if (userEmail.isEmpty) {
        state = AsyncValue.error("Email not found", StackTrace.current);
        return false;
      }

      final isSuccess = await PasswordRecoveryRepository.instance.updatePassword(
        email: userEmail,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      if (isSuccess) {
        state = const AsyncValue.data(true);
        return true;
      } else {
        state = AsyncValue.error("Failed to update password", StackTrace.current);
        return false;
      }
    } catch (e, stackTrace) {
      errorLog("ResetPasswordNotifier.updatePassword", e);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}
