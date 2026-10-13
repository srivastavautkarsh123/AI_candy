import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration options for candychatting.
class DefaultFirebaseOptions {
  static bool get hasValidStaticConfig => true;

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
    apiKey: 'AIzaSyDebL8Ev5QJ0dj8g-q_cK-9O4tuhEq6UuM',
    appId: '1:588872692639:ios:9472288f92b09287bd83aa',
    messagingSenderId: '588872692639',
    projectId: 'candychatting',
    storageBucket: 'candychatting.firebasestorage.app',
    iosBundleId: 'com.example.candyAi',
  );
}
