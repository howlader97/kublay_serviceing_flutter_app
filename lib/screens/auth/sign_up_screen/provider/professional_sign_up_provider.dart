import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/services/repository/auth_repository.dart';
import 'package:belwork/utils/app_log.dart';

final professionalSignUpProvider =
    StateNotifierProvider<ProfessionalSignUpNotifier, AsyncValue<bool>>((ref) {
  return ProfessionalSignUpNotifier();
});

class ProfessionalSignUpNotifier extends StateNotifier<AsyncValue<bool>> {
  ProfessionalSignUpNotifier() : super(const AsyncValue.data(false));

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String corporateVatNumber,
    required String availability,
    required String categories,
    String? cbeSecurityFilePath,
  }) async {
    state = const AsyncValue.loading();
    try {

      final isSuccess = await AuthRepository.instance.professionalSignUp(
        name: name,
        email: email,
        password: password,
        corporateVatNumber: corporateVatNumber,
        availability: availability,
        categories: categories,
        cbeSecurityFilePath: cbeSecurityFilePath,
      );
      if (isSuccess) {
        state = const AsyncValue.data(true);
        return true;
      } else {
        state = AsyncValue.error("Professional Sign Up failed", StackTrace.current);
        return false;
      }
    } catch (e, stackTrace) {
      errorLog("ProfessionalSignUpNotifier signUp error", e);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}
