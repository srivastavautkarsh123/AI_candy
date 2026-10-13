import 'dart:convert';

class CharacterModel {
  final String id;
  final String name;
  final int age;
  final String tagline;
  final String bio;
  final String greeting;

  // Candy AI Appearance & Creation Attributes
  final String style; // 'Realistic' or 'Anime'
  final String gender; // 'Female', 'Male', 'Non-Binary'
  final String ethnicity;
  final String eyeColor;
  final String hairStyle;
  final String hairColor;
  final String bodyType;
  final String outfit;

  // Persona & Roleplay Attributes
  final String personality;
  final String occupation;
  final String relationship;
  final List<String> hobbies;

  // Voice Settings
  final String voiceStyle;
  final double voicePitch;
  final double voiceRate;

  // Media & Social Stats
  final String avatarUrl;
  final List<String> galleryUrls;
  final bool isCustom;
  final bool isFavorite;
  final int likesCount;
  final String messagesCount;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.age,
    required this.tagline,
    required this.bio,
    required this.greeting,
    required this.style,
    required this.gender,
    required this.ethnicity,
    required this.eyeColor,
    required this.hairStyle,
    required this.hairColor,
    required this.bodyType,
    required this.outfit,
    required this.personality,
    required this.occupation,
    required this.relationship,
    required this.hobbies,
    this.voiceStyle = 'Warm & Expressive',
    this.voicePitch = 1.1,
    this.voiceRate = 0.48,
    required this.avatarUrl,
    required this.galleryUrls,
    this.isCustom = false,
    this.isFavorite = false,
    this.likesCount = 1240,
    this.messagesCount = '42.5K',
  });

  CharacterModel copyWith({
    String? id,
    String? name,
    int? age,
    String? tagline,
    String? bio,
    String? greeting,
    String? style,
    String? gender,
    String? ethnicity,
    String? eyeColor,
    String? hairStyle,
    String? hairColor,
    String? bodyType,
    String? outfit,
    String? personality,
    String? occupation,
    String? relationship,
    List<String>? hobbies,
    String? voiceStyle,
    double? voicePitch,
    double? voiceRate,
    String? avatarUrl,
    List<String>? galleryUrls,
    bool? isCustom,
    bool? isFavorite,
    int? likesCount,
    String? messagesCount,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      tagline: tagline ?? this.tagline,
      bio: bio ?? this.bio,
      greeting: greeting ?? this.greeting,
      style: style ?? this.style,
      gender: gender ?? this.gender,
      ethnicity: ethnicity ?? this.ethnicity,
      eyeColor: eyeColor ?? this.eyeColor,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      bodyType: bodyType ?? this.bodyType,
      outfit: outfit ?? this.outfit,
      personality: personality ?? this.personality,
      occupation: occupation ?? this.occupation,
      relationship: relationship ?? this.relationship,
      hobbies: hobbies ?? this.hobbies,
      voiceStyle: voiceStyle ?? this.voiceStyle,
      voicePitch: voicePitch ?? this.voicePitch,
      voiceRate: voiceRate ?? this.voiceRate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      isCustom: isCustom ?? this.isCustom,
      isFavorite: isFavorite ?? this.isFavorite,
      likesCount: likesCount ?? this.likesCount,
      messagesCount: messagesCount ?? this.messagesCount,
    );
  }

  String get appearancePrompt {
    final styleDesc = style == 'Anime'
        ? 'masterpiece anime illustration, vibrant studio anime lighting, detailed anime eyes'
        : 'ultra realistic 8k portrait photography, cinematic lighting, shallow depth of field, photorealistic skin texture';
    return '$styleDesc, $age year old $ethnicity $gender, $hairColor $hairStyle hair, $eyeColor eyes, $bodyType build, wearing $outfit, $personality expression';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'tagline': tagline,
      'bio': bio,
      'greeting': greeting,
      'style': style,
      'gender': gender,
      'ethnicity': ethnicity,
      'eyeColor': eyeColor,
      'hairStyle': hairStyle,
      'hairColor': hairColor,
      'bodyType': bodyType,
      'outfit': outfit,
      'personality': personality,
      'occupation': occupation,
      'relationship': relationship,
      'hobbies': hobbies,
      'voiceStyle': voiceStyle,
      'voicePitch': voicePitch,
      'voiceRate': voiceRate,
      'avatarUrl': avatarUrl,
      'galleryUrls': galleryUrls,
      'isCustom': isCustom,
      'isFavorite': isFavorite,
      'likesCount': likesCount,
      'messagesCount': messagesCount,
    };
  }

  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    return CharacterModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 22,
      tagline: map['tagline'] ?? '',
      bio: map['bio'] ?? '',
      greeting: map['greeting'] ?? '',
      style: map['style'] ?? 'Realistic',
      gender: map['gender'] ?? 'Female',
      ethnicity: map['ethnicity'] ?? 'Caucasian',
      eyeColor: map['eyeColor'] ?? 'Blue',
      hairStyle: map['hairStyle'] ?? 'Long Wavy',
      hairColor: map['hairColor'] ?? 'Blonde',
      bodyType: map['bodyType'] ?? 'Slim',
      outfit: map['outfit'] ?? 'Casual Chic',
      personality: map['personality'] ?? 'Playful & Flirty',
      occupation: map['occupation'] ?? 'Model',
      relationship: map['relationship'] ?? 'Crush',
      hobbies: List<String>.from(map['hobbies'] ?? const []),
      voiceStyle: map['voiceStyle'] ?? 'Warm & Expressive',
      voicePitch: (map['voicePitch'] ?? 1.1).toDouble(),
      voiceRate: (map['voiceRate'] ?? 0.48).toDouble(),
      avatarUrl: map['avatarUrl'] ?? '',
      galleryUrls: List<String>.from(map['galleryUrls'] ?? const []),
      isCustom: map['isCustom'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
      likesCount: map['likesCount'] ?? 100,
      messagesCount: map['messagesCount'] ?? '1.2K',
    );
  }

  String toJson() => json.encode(toMap());

  factory CharacterModel.fromJson(String source) =>
      CharacterModel.fromMap(json.decode(source));
}
