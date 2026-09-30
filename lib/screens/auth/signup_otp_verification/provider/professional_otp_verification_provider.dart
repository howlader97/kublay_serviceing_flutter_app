import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/services/repository/auth_repository.dart';
import 'package:belwork/utils/app_log.dart';

final professionalOtpVerificationProvider = StateNotifierProvider<
    ProfessionalOtpVerificationNotifier, AsyncValue<bool>>((ref) {
  return ProfessionalOtpVerificationNotifier();
});

class ProfessionalOtpVerificationNotifier
    extends StateNotifier<AsyncValue<bool>> {
  ProfessionalOtpVerificationNotifier()
      : super(const AsyncValue.data(false));

  Future<bool> verifyOtp({required String email, required String otp}) async {
    state = const AsyncValue.loading();
    try {
      final isSuccess = await AuthRepository.instance.professionalOtpVerify(
        email: email,
        otp: otp,
      );
      if (isSuccess) {
        state = const AsyncValue.data(true);
        return true;
      } else {
        state = AsyncValue.error(
            "Professional OTP Verification failed", StackTrace.current);
        return false;
      }
    } catch (e, stackTrace) {
      errorLog("ProfessionalOtpVerificationNotifier verifyOtp error", e);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  Future<bool> resendOtp({required String email}) async {
    try {
      return await AuthRepository.instance.authResendOTP(email: email);
    } catch (e) {
      errorLog("ProfessionalOtpVerificationNotifier resendOtp error", e);
      return false;
    }
  }
}
