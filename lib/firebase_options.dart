// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
      return web;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB9lW-BQHLB7FLVOPcjowQEardc8kP-Hso',
    appId: '1:958816291653:web:53d0827a45b49b55350c2c',
    messagingSenderId: '958816291653',
    projectId: 'poopootracker',
    authDomain: 'poopootracker.firebaseapp.com',
    storageBucket: 'poopootracker.firebasestorage.app',
    measurementId: 'G-L606XFXRD5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAR4O6vEIT-olBpOgqzPr38N5yyNDsyOAs',
    appId: '1:958816291653:android:cffdbb208a694eb8350c2c',
    messagingSenderId: '958816291653',
    projectId: 'poopootracker',
    storageBucket: 'poopootracker.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCGNq4yjAAAb_o82I_W7BCUDuz83jtYQl8',
    appId: '1:958816291653:ios:1c60e07df7e8f1d4350c2c',
    messagingSenderId: '958816291653',
    projectId: 'poopootracker',
    storageBucket: 'poopootracker.firebasestorage.app',
    iosBundleId: 'com.dal.poopapp.poopapp',
  );
}
