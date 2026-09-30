import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:belwork/utils/app_log.dart';

class GoogleAuthService {
  GoogleAuthService._internal();

  static final GoogleAuthService _instance = GoogleAuthService._internal();
  static GoogleAuthService get instance => _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  Future<String?> signInAndGetIdToken() async {
    try {
      appLog('GoogleAuthService: Starting Google Sign-In process...');


      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        appLog('GoogleAuthService: User cancelled Google Sign-In dialog');
        return null;
      }

      appLog('GoogleAuthService: Google Account selected: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) {
        errorLog('GoogleAuthService', 'Firebase user is null after sign in');
        return null;
      }


      final String? idToken = await user.getIdToken(true);

      if (idToken == null || idToken.isEmpty) {
        errorLog('GoogleAuthService', 'Failed to retrieve Firebase ID Token');
        return null;
      }

      appLog('GoogleAuthService: Firebase ID Token successfully generated');
      return idToken;
    } on FirebaseAuthException catch (e) {
      errorLog('GoogleAuthService: FirebaseAuthException', '${e.code}: ${e.message}');
      return null;
    } on PlatformException catch (e) {
      errorLog('GoogleAuthService: PlatformException', '${e.code}: ${e.message}');
      return null;
    } catch (e) {
      errorLog('GoogleAuthService: Unexpected error during Google Sign-In', e);
      return null;
    }
  }

  /// Attempts silent Google Sign-In (if already signed in on device) and returns fresh Firebase ID Token
  Future<String?> silentSignInAndGetIdToken() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signInSilently();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return await userCredential.user?.getIdToken(true);
    } catch (e) {
      errorLog('GoogleAuthService.silentSignInAndGetIdToken error', e);
      return null;
    }
  }

  /// Returns current Firebase ID Token if user is currently authenticated with Firebase
  Future<String?> getCurrentFirebaseIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      errorLog('GoogleAuthService.getCurrentFirebaseIdToken error', e);
      return null;
    }
  }

  /// Signs out from both Google Sign-In and Firebase Auth
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);
      appLog('GoogleAuthService: Successfully signed out from Google and Firebase');
    } catch (e) {
      errorLog('GoogleAuthService.signOut error', e);
    }
  }

  /// Disconnects Google account completely (revokes access)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      await _firebaseAuth.signOut();
      appLog('GoogleAuthService: Successfully disconnected Google account');
    } catch (e) {
      errorLog('GoogleAuthService.disconnect error', e);
    }
  }

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isSignedIn => _firebaseAuth.currentUser != null;
}