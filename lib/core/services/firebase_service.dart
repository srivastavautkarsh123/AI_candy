import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../firebase_options.dart';
import '../../models/character_model.dart';
import '../../models/user_model.dart';

class FirebaseService extends ChangeNotifier {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  static const String _prefApiKey = 'fb_custom_api_key';
  static const String _prefAppId = 'fb_custom_app_id';
  static const String _prefProjectId = 'fb_custom_project_id';
  static const String _prefSenderId = 'fb_custom_sender_id';

  bool _isConnected = false;
  String? _connectedProjectId;
  String? _lastError;

  bool get isConnected => _isConnected;
  String? get connectedProjectId => _connectedProjectId;
  String? get lastError => _lastError;

  /// Initializes Firebase using either saved runtime credentials or DefaultFirebaseOptions
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isConnected = true;
        _connectedProjectId = Firebase.app().options.projectId;
        notifyListeners();
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final customApiKey = prefs.getString(_prefApiKey) ?? '';
      final customAppId = prefs.getString(_prefAppId) ?? '';
      final customProjectId = prefs.getString(_prefProjectId) ?? '';
      final customSenderId = prefs.getString(_prefSenderId) ?? '000000000000';

      if (customApiKey.isNotEmpty &&
          customAppId.isNotEmpty &&
          customProjectId.isNotEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: customApiKey,
            appId: customAppId,
            messagingSenderId: customSenderId,
            projectId: customProjectId,
            authDomain: '$customProjectId.firebaseapp.com',
            storageBucket: '$customProjectId.firebasestorage.app',
          ),
        );
        _isConnected = true;
        _connectedProjectId = customProjectId;
        _lastError = null;
      } else if (DefaultFirebaseOptions.hasValidStaticConfig) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _isConnected = true;
        _connectedProjectId = DefaultFirebaseOptions.currentPlatform.projectId;
        _lastError = null;
      }
    } catch (e) {
      _isConnected = false;
      _lastError = e.toString();
      debugPrint('Firebase init notice (running in local hybrid mode): $e');
    }
    notifyListeners();
  }

  /// Connects a Firebase project dynamically at runtime using keys from the UI
  Future<bool> configureAndConnect({
    required String apiKey,
    required String appId,
    required String projectId,
    String messagingSenderId = '000000000000',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefApiKey, apiKey.trim());
      await prefs.setString(_prefAppId, appId.trim());
      await prefs.setString(_prefProjectId, projectId.trim());
      await prefs.setString(_prefSenderId, messagingSenderId.trim());

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: apiKey.trim(),
            appId: appId.trim(),
            messagingSenderId: messagingSenderId.trim(),
            projectId: projectId.trim(),
            authDomain: '${projectId.trim()}.firebaseapp.com',
            storageBucket: '${projectId.trim()}.firebasestorage.app',
          ),
        );
      }
      _isConnected = true;
      _connectedProjectId = projectId.trim();
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Firebase Google OAuth / Anonymous Auth when Firebase is connected
  Future<UserCredential?> signInWithFirebaseProvider(String providerName) async {
    if (!_isConnected) return null;
    try {
      final auth = FirebaseAuth.instance;
      if (providerName == 'Google' && kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        return await auth.signInWithPopup(googleProvider);
      }
      return await auth.signInAnonymously();
    } catch (e) {
      debugPrint('Firebase Auth fallback: $e');
      return null;
    }
  }

  /// Syncs User Profile to Cloud Firestore
  Future<void> syncUserToFirestore(UserModel user) async {
    if (!_isConnected) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore user sync warning: $e');
    }
  }

  /// Syncs Custom Created AI Character to Cloud Firestore
  Future<void> syncCharacterToFirestore(CharacterModel character) async {
    if (!_isConnected) return;
    try {
      await FirebaseFirestore.instance
          .collection('characters')
          .doc(character.id)
          .set(character.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore character sync warning: $e');
    }
  }
}
