import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/services/repository/password_recovery_repository.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/utils/app_log.dart';

final otpVerificationProvider =
    StateNotifierProvider<OtpVerificationNotifier, AsyncValue<bool>>((ref) {
  return OtpVerificationNotifier();
});

class OtpVerificationNotifier extends StateNotifier<AsyncValue<bool>> {
  OtpVerificationNotifier() : super(const AsyncValue.data(false));

  Future<bool> verifyOtp({required String otp, String? email}) async {
    state = const AsyncValue.loading();
    try {
      final userEmail = email ?? await StorageServices.instance.getForgotPasswordEmail();
      if (userEmail.isEmpty) {
        state = AsyncValue.error("Email not found", StackTrace.current);
        return false;
      }

      final isSuccess = await PasswordRecoveryRepository.instance.verifyOtp(
        email: userEmail,
        otp: otp,
      );
      if (isSuccess) {
        state = const AsyncValue.data(true);
        return true;
      } else {
        state = AsyncValue.error("OTP verification failed", StackTrace.current);
        return false;
      }
    } catch (e, stackTrace) {
      errorLog("OtpVerificationNotifier.verifyOtp", e);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  Future<bool> resendOtp({String? email}) async {
    try {
      final userEmail = email ?? await StorageServices.instance.getForgotPasswordEmail();
      if (userEmail.isEmpty) return false;
      return await PasswordRecoveryRepository.instance.sendOtp(email: userEmail);
    } catch (e) {
      errorLog("OtpVerificationNotifier.resendOtp", e);
      return false;
    }
  }
}
