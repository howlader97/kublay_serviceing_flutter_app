import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/services/repository/password_recovery_repository.dart';
import 'package:belwork/utils/app_log.dart';

final emailVerificationProvider =
    StateNotifierProvider<EmailVerificationNotifier, AsyncValue<bool>>((ref) {
  return EmailVerificationNotifier();
});

class EmailVerificationNotifier extends StateNotifier<AsyncValue<bool>> {
  EmailVerificationNotifier() : super(const AsyncValue.data(false));

  Future<bool> sendOtp({required String email}) async {
    state = const AsyncValue.loading();
    try {
      final isSuccess = await PasswordRecoveryRepository.instance.sendOtp(
        email: email,
      );
      if (isSuccess) {
        state = const AsyncValue.data(true);
        return true;
      } else {
        state = AsyncValue.error("Failed to send OTP", StackTrace.current);
        return false;
      }
    } catch (e, stackTrace) {
      errorLog("EmailVerificationNotifier.sendOtp", e);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}
