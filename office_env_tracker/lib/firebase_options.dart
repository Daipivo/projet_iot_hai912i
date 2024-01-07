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
    apiKey: 'AIzaSyD9FWJKrJF7q93V1H0V0vdk8jVjD2Dr6CI',
    appId: '1:709930555751:web:5cf1aa4e2d01ada801b7c2',
    messagingSenderId: '709930555751',
    projectId: 'iotprojectdatabase',
    authDomain: 'iotprojectdatabase.firebaseapp.com',
    storageBucket: 'iotprojectdatabase.appspot.com',
    measurementId: 'G-WMBP4ZK5E4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAFjp6-XsxBXVbY8wHjPSIpXCVRoWPYbkU',
    appId: '1:709930555751:android:dd6559a7e8750c8101b7c2',
    messagingSenderId: '709930555751',
    projectId: 'iotprojectdatabase',
    storageBucket: 'iotprojectdatabase.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1qFwZ4E2jgEvMAHDujB2Ydb7bsOtaEkc',
    appId: '1:709930555751:ios:a2c49effe380067701b7c2',
    messagingSenderId: '709930555751',
    projectId: 'iotprojectdatabase',
    storageBucket: 'iotprojectdatabase.appspot.com',
    iosBundleId: 'com.example.officeEnvTracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB1qFwZ4E2jgEvMAHDujB2Ydb7bsOtaEkc',
    appId: '1:709930555751:ios:a672de6f5dc350d901b7c2',
    messagingSenderId: '709930555751',
    projectId: 'iotprojectdatabase',
    storageBucket: 'iotprojectdatabase.appspot.com',
    iosBundleId: 'com.example.officeEnvTracker.RunnerTests',
  );
}