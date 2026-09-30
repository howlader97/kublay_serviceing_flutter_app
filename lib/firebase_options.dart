import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAF1w63nSbN0W49RVEDoyodcpVNhL5p29E',
    appId: '1:250116583629:android:4432a16b31c55b341e3984',
    messagingSenderId: '250116583629',
    projectId: 'belwork-83353',
    storageBucket: 'belwork-83353.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAVcJD2lmqPJmQJFuSKLio2mdPVZXKCzPs',
    appId: '1:250116583629:ios:feed4e7d05c13a101e3984',
    messagingSenderId: '250116583629',
    projectId: 'belwork-83353',
    storageBucket: 'belwork-83353.firebasestorage.app',
    iosClientId: '250116583629-dl5rk1ekv5e66ajb9mbtfiag2rpt5cp5.apps.googleusercontent.com',
    iosBundleId: 'com.topackubilayapp.belworkapp',
  );
}
