import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options.
/// You can either replace the placeholder values below with your Firebase project
/// keys from the Firebase Console (Project Settings -> Your Apps), or enter them
/// directly inside the app's "Firebase & LLM API Settings" screen!
class DefaultFirebaseOptions {
  static const String _apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'YOUR_FIREBASE_API_KEY',
  );
  static const String _appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: 'YOUR_FIREBASE_APP_ID',
  );
  static const String _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: 'YOUR_SENDER_ID',
  );
  static const String _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'YOUR_PROJECT_ID',
  );

  static bool get hasValidStaticConfig =>
      _apiKey != 'YOUR_FIREBASE_API_KEY' && _projectId != 'YOUR_PROJECT_ID';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDebL8Ev5QJ0dj8g-q_cK-9O4tuhEq6UuM',
    appId: '1:588872692639:web:9472288f92b09287bd83aa',
    messagingSenderId: '588872692639',
    projectId: 'candychatting',
    authDomain: 'candychatting.firebaseapp.com',
    storageBucket: 'candychatting.firebasestorage.app',
    measurementId: 'G-VLPJLN3GS7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQstpVK_nUQ7YXkssHML4JkXZKR_WIaNQ',
    appId: '1:588872692639:android:20db7b35ec12451ebd83aa',
    messagingSenderId: '588872692639',
    projectId: 'candychatting',
    storageBucket: 'candychatting.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: '$_projectId.firebasestorage.app',
    iosBundleId: 'com.example.candyAi',
  );
}
