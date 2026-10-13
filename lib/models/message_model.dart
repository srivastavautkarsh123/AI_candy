import 'dart:convert';

class MessageModel {
  final String id;
  final String characterId;
  final bool isUser;
  final String text;
  final String? imageUrl;
  final String? imagePrompt;
  final DateTime timestamp;

  const MessageModel({
    required this.id,
    required this.characterId,
    required this.isUser,
    required this.text,
    this.imageUrl,
    this.imagePrompt,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'characterId': characterId,
      'isUser': isUser,
      'text': text,
      'imageUrl': imageUrl,
      'imagePrompt': imagePrompt,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      characterId: map['characterId'] ?? '',
      isUser: map['isUser'] ?? false,
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      imagePrompt: map['imagePrompt'],
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source));
}
