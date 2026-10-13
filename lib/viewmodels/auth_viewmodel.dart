import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../core/services/firebase_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  static const String _userPrefsKey = 'candy_ai_current_user';

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_userPrefsKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        _currentUser = UserModel.fromJson(savedJson);
      }
    } catch (e) {
      debugPrint('Failed to load user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUser(UserModel user) async {
    _currentUser = user;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPrefsKey, user.toJson());
    // Sync to Cloud Firestore if Firebase project is connected
    await FirebaseService().syncUserToFirestore(user);
  }

  /// Sign in with third-party OAuth provider (Google, Discord, Apple) for free
  Future<void> signInWithThirdParty({
    required String providerName,
    String? customName,
    String? customEmail,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Attempt live Firebase Auth if a Firebase project is connected
    final fbCred =
        await FirebaseService().signInWithFirebaseProvider(providerName);

    await Future.delayed(const Duration(milliseconds: 500));

    final fbUser = fbCred?.user;
    final name = customName?.trim().isNotEmpty == true
        ? customName!.trim()
        : (fbUser?.displayName?.isNotEmpty == true
              ? fbUser!.displayName!
              : '$providerName Explorer');
    final email = customEmail?.trim().isNotEmpty == true
        ? customEmail!.trim()
        : (fbUser?.email?.isNotEmpty == true
              ? fbUser!.email!
              : '${providerName.toLowerCase()}.user@candyai.app');

    final user = UserModel(
      id: fbUser?.uid ?? const Uuid().v4(),
      name: name,
      email: email,
      avatarUrl: fbUser?.photoURL ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop&q=80',
      authProvider: providerName,
      tokens: 150, // Free welcome tokens
      isPro: false,
      lastDailyReward: DateTime.now(),
    );

    await _saveUser(user);
    _isLoading = false;
    notifyListeners();
  }

  /// Spend tokens for chat or image generation (free for Pro users)
  Future<bool> spendTokens(int amount) async {
    if (_currentUser == null) return false;
    if (_currentUser!.isPro) return true;
    if (_currentUser!.tokens < amount) return false;

    final updated = _currentUser!.copyWith(
      tokens: _currentUser!.tokens - amount,
    );
    await _saveUser(updated);
    return true;
  }

  /// Claim free bonus tokens
  Future<void> addFreeTokens(int amount) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      tokens: _currentUser!.tokens + amount,
      lastDailyReward: DateTime.now(),
    );
    await _saveUser(updated);
  }

  /// Toggle Candy Pro membership
  Future<void> upgradeToPro() async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      isPro: true,
      tokens: _currentUser!.tokens + 500,
    );
    await _saveUser(updated);
  }

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userPrefsKey);
  }
}
