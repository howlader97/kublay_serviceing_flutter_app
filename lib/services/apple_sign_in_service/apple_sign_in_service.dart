import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:belwork/utils/app_log.dart';

class AppleAuthResult {
  final String identityToken;
  final String? name;
  final String? email;

  AppleAuthResult({required this.identityToken, this.name, this.email});
}

class AppleAuthService {
  AppleAuthService._internal();

  static final AppleAuthService _instance = AppleAuthService._internal();
  static AppleAuthService get instance => _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<AppleAuthResult?> signInWithApple() async {
    try {
      appLog('AppleAuthService: Starting Apple Sign-In process...');

      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String? identityToken = credential.identityToken;

      if (identityToken == null || identityToken.isEmpty) {
        errorLog('AppleAuthService', 'Failed to retrieve Apple Identity Token');
        return null;
      }

      // Format user's name if provided (Apple only sends this on initial sign-in)
      String? name;
      final givenName = credential.givenName;
      final familyName = credential.familyName;
      if ((givenName != null && givenName.isNotEmpty) ||
          (familyName != null && familyName.isNotEmpty)) {
        name = [givenName, familyName]
            .where((part) => part != null && part.isNotEmpty)
            .join(' ');
      }

      final String? email = credential.email;

      // Optional: Authenticate with Firebase Auth as well
      try {
        final OAuthCredential oauthCredential =
            OAuthProvider('apple.com').credential(
          idToken: identityToken,
        );
        await _firebaseAuth.signInWithCredential(oauthCredential);
      } catch (e) {
        appLog('Firebase sign-in with Apple credential note: $e');
      }

      appLog('AppleAuthService: Real Apple Identity Token generated successfully');

      return AppleAuthResult(
        identityToken: identityToken,
        name: name,
        email: email,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        appLog('AppleAuthService: User cancelled Apple Sign-In dialog');
        return null;
      }
      errorLog(
        'AppleAuthService: SignInWithAppleAuthorizationException',
        '${e.code}: ${e.message}',
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' ||
          e.code == 'user-cancelled' ||
          e.code == 'web-context-cancelled' ||
          e.code == 'popup-closed-by-user' ||
          (e.message?.contains('1001') ?? false)) {
        appLog('AppleAuthService: User cancelled Apple Sign-In dialog');
        return null;
      }
      errorLog(
        'AppleAuthService: FirebaseAuthException',
        '${e.code}: ${e.message}',
      );
      return null;
    } on PlatformException catch (e) {
      if (e.code == 'canceled' ||
          e.code == '1001' ||
          (e.message?.contains('1001') ?? false)) {
        appLog('AppleAuthService: User cancelled Apple Sign-In');
        return null;
      }
      errorLog(
        'AppleAuthService: PlatformException',
        '${e.code}: ${e.message}',
      );
      return null;
    } catch (e) {
      errorLog('AppleAuthService: Unexpected error during Apple Sign-In', e);
      return null;
    }
  }

  /// Signs out from Firebase Auth
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      appLog('AppleAuthService: Successfully signed out from Firebase');
    } catch (e) {
      errorLog('AppleAuthService.signOut error', e);
    }
  }

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isSignedIn => _firebaseAuth.currentUser != null;
}
