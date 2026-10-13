import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String authProvider; // 'Google', 'Discord', 'Apple', 'Email'
  final int tokens;
  final bool isPro;
  final DateTime lastDailyReward;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.authProvider,
    this.tokens = 100,
    this.isPro = false,
    required this.lastDailyReward,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? authProvider,
    int? tokens,
    bool? isPro,
    DateTime? lastDailyReward,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authProvider: authProvider ?? this.authProvider,
      tokens: tokens ?? this.tokens,
      isPro: isPro ?? this.isPro,
      lastDailyReward: lastDailyReward ?? this.lastDailyReward,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'authProvider': authProvider,
      'tokens': tokens,
      'isPro': isPro,
      'lastDailyReward': lastDailyReward.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Candy Explorer',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      authProvider: map['authProvider'] ?? 'Google',
      tokens: map['tokens'] ?? 100,
      isPro: map['isPro'] ?? false,
      lastDailyReward: map['lastDailyReward'] != null
          ? DateTime.tryParse(map['lastDailyReward']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
