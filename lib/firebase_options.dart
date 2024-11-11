// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return macos;
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
    apiKey: 'AIzaSyCQKe5pqCZWWG0-mBsQzyShsGSsIPoIf3s',
    appId: '1:628324037080:web:e62a58e373b73ff0ddc2ad',
    messagingSenderId: '628324037080',
    projectId: 'internationalweek-f1e7d',
    authDomain: 'internationalweek-f1e7d.firebaseapp.com',
    storageBucket: 'internationalweek-f1e7d.appspot.com',
    measurementId: 'G-4BT756L848',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPAo9cfl_8akhr7R3s-J1HV3qAyY71CJ8',
    appId: '1:628324037080:android:49756ee015898e4cddc2ad',
    messagingSenderId: '628324037080',
    projectId: 'internationalweek-f1e7d',
    storageBucket: 'internationalweek-f1e7d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCuPJDaj825TZgKH8HydQHGONNMeBT7aJs',
    appId: '1:628324037080:ios:07aeed3b95ff8170ddc2ad',
    messagingSenderId: '628324037080',
    projectId: 'internationalweek-f1e7d',
    storageBucket: 'internationalweek-f1e7d.appspot.com',
    iosBundleId: 'com.example.iwAdminPanel',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCuPJDaj825TZgKH8HydQHGONNMeBT7aJs',
    appId: '1:628324037080:ios:dd9453f59489f6f4ddc2ad',
    messagingSenderId: '628324037080',
    projectId: 'internationalweek-f1e7d',
    storageBucket: 'internationalweek-f1e7d.appspot.com',
    iosBundleId: 'com.example.iwAdminPanel.RunnerTests',
  );
}
