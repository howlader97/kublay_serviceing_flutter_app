import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/services/repository/auth_repository.dart';
import 'package:belwork/utils/app_log.dart';

final signUpProvider = StateNotifierProvider<SignUpNotifier, AsyncValue<bool>>((ref) {
  return SignUpNotifier();
});

class SignUpNotifier extends StateNotifier<AsyncValue<bool>> {
  SignUpNotifier() : super(const AsyncValue.data(false));

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final isSuccess = await AuthRepository.instance.signUp(
        name: name,
        email: email,
        password: password,
      );
      if (isSuccess) {
        state = const AsyncValue.data(true);
        return true;
      } else {
        state = AsyncValue.error("Sign up failed", StackTrace.current);
        return false;
      }
    } catch (e, stackTrace) {
      errorLog("SignUpNotifier signUp error", e);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}
