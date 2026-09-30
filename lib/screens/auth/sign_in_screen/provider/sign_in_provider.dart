import 'package:belwork/screens/chat_screen/provider/chat_provider.dart';
import 'package:belwork/screens/customer_screen/customer_profile_screen/provider/customer_profile_provider.dart';
import 'package:belwork/screens/technician_screen/technician_profile_screen/provider/technician_profile_provider.dart';
import 'package:belwork/services/apple_sign_in_service/apple_sign_in_service.dart';
import 'package:belwork/services/google_sign_in_service/google_sign_in_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/services/repository/auth_repository.dart';
import 'package:belwork/utils/app_log.dart';

final signInProvider = StateNotifierProvider<SignInNotifier, AsyncValue<bool>>((ref) {
  return SignInNotifier(ref);
});

final googleSignInProvider = StateNotifierProvider<GoogleSignInNotifier, AsyncValue<bool>>((ref) {
  return GoogleSignInNotifier(ref);
});

final appleSignInProvider = StateNotifierProvider<AppleSignInNotifier, AsyncValue<bool>>((ref) {
  return AppleSignInNotifier(ref);
});

class SignInNotifier extends StateNotifier<AsyncValue<bool>> {
  SignInNotifier(this._ref) : super(const AsyncValue.data(false));
  final Ref _ref;

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final isSuccess = await AuthRepository.instance.login(
        email: email,
        password: password,
      );
      if (isSuccess) {
        _ref.invalidate(chatListProvider);
        _ref.invalidate(singleChatProvider);
        _ref.invalidate(userProfileProvider);
        _ref.invalidate(technicianProfileProvider);

        state = const AsyncValue.data(true);
        return true;
      } else {
        state = AsyncValue.error("Login failed", StackTrace.current);
        return false;
      }
    } catch (e, stackTrace) {
      errorLog("SignInNotifier login error", e);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}

class GoogleSignInNotifier extends StateNotifier<AsyncValue<bool>> {
  GoogleSignInNotifier(this._ref) : super(const AsyncValue.data(false));
  final Ref _ref;

  Future<bool> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final idToken = await GoogleAuthService.instance.signInAndGetIdToken();
      if (idToken == null || idToken.isEmpty) {
        state = const AsyncValue.data(false);
        return false;
      }

      final isSuccess = await AuthRepository.instance.googleLogin(
        idToken: idToken,
      );

      if (isSuccess) {
        _ref.invalidate(chatListProvider);
        _ref.invalidate(singleChatProvider);
        _ref.invalidate(userProfileProvider);
        _ref.invalidate(technicianProfileProvider);

        state = const AsyncValue.data(true);
        return true;
      } else {
        state = AsyncValue.error("Google Sign-In failed", StackTrace.current);
        return false;
      }
    } catch (e, stackTrace) {
      errorLog("GoogleSignInNotifier.signInWithGoogle error", e);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}

class AppleSignInNotifier extends StateNotifier<AsyncValue<bool>> {
  AppleSignInNotifier(this._ref) : super(const AsyncValue.data(false));
  final Ref _ref;

  Future<bool> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final result = await AppleAuthService.instance.signInWithApple();
      if (result == null || result.identityToken.isEmpty) {
        state = const AsyncValue.data(false);
        return false;
      }

      final isSuccess = await AuthRepository.instance.appleLogin(
        identityToken: result.identityToken,
        name: result.name,
        email: result.email,
      );

      if (isSuccess) {
        _ref.invalidate(chatListProvider);
        _ref.invalidate(singleChatProvider);
        _ref.invalidate(userProfileProvider);
        _ref.invalidate(technicianProfileProvider);

        state = const AsyncValue.data(true);
        return true;
      } else {
        state = AsyncValue.error("Apple Sign-In failed", StackTrace.current);
        return false;
      }
    } catch (e, stackTrace) {
      errorLog("AppleSignInNotifier.signInWithApple error", e);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}
