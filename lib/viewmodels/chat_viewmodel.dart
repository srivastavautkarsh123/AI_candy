import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../core/services/ai_service.dart';
import '../models/character_model.dart';
import '../models/message_model.dart';

class ChatViewModel extends ChangeNotifier {
  static const String _chatStoragePrefix = 'candy_ai_chat_';

  final Map<String, List<MessageModel>> _conversations = {};
  final Set<String> _typingCharacterIds = {};

  bool isTyping(String characterId) => _typingCharacterIds.contains(characterId);

  List<MessageModel> getMessagesFor(CharacterModel character) {
    if (!_conversations.containsKey(character.id)) {
      // Seed with character's initial greeting message
      _conversations[character.id] = [
        MessageModel(
          id: 'greeting_${character.id}',
          characterId: character.id,
          isUser: false,
          text: character.greeting,
          imageUrl: character.avatarUrl,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ];
      _loadMessagesFromDisk(character.id);
    }
    return List.unmodifiable(_conversations[character.id]!);
  }

  /// Returns IDs of characters that have active conversations
  List<String> get activeCharacterIds => _conversations.keys.toList();

  Future<void> _loadMessagesFromDisk(String characterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList('$_chatStoragePrefix$characterId');
      if (rawList != null && rawList.isNotEmpty) {
        _conversations[characterId] =
            rawList.map((e) => MessageModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load chat history: $e');
    }
  }

  Future<void> _saveMessagesToDisk(String characterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _conversations[characterId] ?? [];
      await prefs.setStringList(
        '$_chatStoragePrefix$characterId',
        list.map((m) => json.encode(m.toMap())).toList(),
      );
    } catch (e) {
      debugPrint('Failed to save chat history: $e');
    }
  }

  Future<void> sendMessage({
    required CharacterModel character,
    required String text,
    bool forcePhoto = false,
  }) async {
    if (text.trim().isEmpty && !forcePhoto) return;

    final currentList = List<MessageModel>.from(getMessagesFor(character));
    final userMsg = MessageModel(
      id: const Uuid().v4(),
      characterId: character.id,
      isUser: true,
      text: text.trim().isEmpty ? 'Can you send me a selfie right now? 📸' : text.trim(),
      timestamp: DateTime.now(),
    );

    currentList.add(userMsg);
    _conversations[character.id] = currentList;
    _typingCharacterIds.add(character.id);
    notifyListeners();
    await _saveMessagesToDisk(character.id);

    final aiResult = await AiService.generateReply(
      character: character,
      userMessage: userMsg.text,
      history: currentList,
      forcePhoto: forcePhoto,
    );

    final aiMsg = MessageModel(
      id: const Uuid().v4(),
      characterId: character.id,
      isUser: false,
      text: aiResult.replyText,
      imageUrl: aiResult.generatedImageUrl,
      imagePrompt: aiResult.imagePrompt,
      timestamp: DateTime.now(),
    );

    final updatedList = List<MessageModel>.from(_conversations[character.id] ?? []);
    updatedList.add(aiMsg);
    _conversations[character.id] = updatedList;
    _typingCharacterIds.remove(character.id);
    notifyListeners();
    await _saveMessagesToDisk(character.id);
  }

  Future<void> clearConversation(CharacterModel character) async {
    _conversations[character.id] = [
      MessageModel(
        id: 'greeting_${character.id}_${DateTime.now().millisecondsSinceEpoch}',
        characterId: character.id,
        isUser: false,
        text: character.greeting,
        imageUrl: character.avatarUrl,
        timestamp: DateTime.now(),
      ),
    ];
    notifyListeners();
    await _saveMessagesToDisk(character.id);
  }
}
