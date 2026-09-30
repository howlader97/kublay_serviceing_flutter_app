import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/services/repository/auth_repository.dart';
import 'package:belwork/utils/app_log.dart';

final otpVerificationProvider =
    StateNotifierProvider<OtpVerificationNotifier, AsyncValue<bool>>((ref) {
  return OtpVerificationNotifier();
});

class OtpVerificationNotifier extends StateNotifier<AsyncValue<bool>> {
  OtpVerificationNotifier() : super(const AsyncValue.data(false));

  Future<bool> verifyOtp({ required String otp,required String email}) async {
    state = const AsyncValue.loading();
    try {
      final isSuccess = await AuthRepository.instance.authOtpVerify(
        otp: otp,
        email: email,
      );
      if (isSuccess) {
        state = const AsyncValue.data(true);
        return true;
      } else {
        state = AsyncValue.error("OTP Verification failed", StackTrace.current);
        return false;
      }
    } catch (e, stackTrace) {
      errorLog("OtpVerificationNotifier verifyOtp error", e);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  Future<bool> resendOtp({required String email}) async {
    try {
      return await AuthRepository.instance.authResendOTP(email: email);
    } catch (e) {
      errorLog("OtpVerificationNotifier resendOtp error", e);
      return false;
    }
  }
}
