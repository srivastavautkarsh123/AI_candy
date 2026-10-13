import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/character_model.dart';
import '../../models/message_model.dart';
import 'llm_config_service.dart';

class AiResponseResult {
  final String replyText;
  final String? generatedImageUrl;
  final String? imagePrompt;

  const AiResponseResult({
    required this.replyText,
    this.generatedImageUrl,
    this.imagePrompt,
  });
}

class AiService {
  static final Random _random = Random();

  /// Generates a live AI portrait URL using Pollinations Flux/SDXL engine
  /// tailored to the character's exact visual traits.
  static String generateCharacterImageUrl({
    required CharacterModel character,
    String sceneContext =
        'smiling warmly at camera, cozy lighting, portrait selfie',
  }) {
    final seed = character.id.hashCode.abs() % 9999 + _random.nextInt(500);
    final rawPrompt =
        '${character.appearancePrompt}, $sceneContext, high quality, masterpiece';
    final encoded = Uri.encodeComponent(rawPrompt);
    return 'https://image.pollinations.ai/prompt/$encoded?width=768&height=1024&seed=$seed&nologo=true';
  }

  /// Generates an initial avatar URL when a user creates a custom character
  static String generateAvatarFromTraits({
    required String style,
    required String gender,
    required int age,
    required String ethnicity,
    required String hairColor,
    required String hairStyle,
    required String eyeColor,
    required String bodyType,
    required String outfit,
    required String personality,
    int? customSeed,
  }) {
    final seed = customSeed ?? _random.nextInt(99999);
    final styleDesc = style == 'Anime'
        ? 'masterpiece anime character portrait, vibrant studio anime lighting, detailed anime eyes'
        : 'ultra realistic 8k portrait photography, cinematic lighting, photorealistic face, shallow depth of field';
    final rawPrompt =
        '$styleDesc, $age year old $ethnicity $gender, $hairColor $hairStyle hair, $eyeColor eyes, $bodyType build, wearing $outfit, $personality expression, looking at viewer';
    final encoded = Uri.encodeComponent(rawPrompt);
    return 'https://image.pollinations.ai/prompt/$encoded?width=768&height=1024&seed=$seed&nologo=true';
  }

  /// Checks if the user is asking for a selfie / photo
  static bool isPhotoRequest(String input) {
    final lower = input.toLowerCase();
    return lower.contains('selfie') ||
        lower.contains('send a photo') ||
        lower.contains('send me a photo') ||
        lower.contains('send a pic') ||
        lower.contains('show me what you') ||
        lower.contains('what are you wearing') ||
        lower.contains('take a picture');
  }

  /// Builds the system persona prompt for the LLM
  static String buildSystemPrompt(CharacterModel character) {
    return '''
You are ${character.name}, a ${character.age}-year-old ${character.ethnicity} ${character.gender}.
Your appearance: ${character.hairColor} ${character.hairStyle} hair, ${character.eyeColor} eyes, ${character.bodyType} build, currently wearing ${character.outfit}.
Your personality: ${character.personality}.
Your occupation: ${character.occupation}.
Your relationship to the user: ${character.relationship}.
Your hobbies: ${character.hobbies.join(', ')}.
Backstory: ${character.bio}

Roleplay Rules:
1. Stay 100% in character as ${character.name}. Never mention being an AI or language model.
2. Include vivid physical actions and expressions inside single asterisks like *smiles warmly and leans closer* followed by engaging, natural dialogue.
3. Keep responses concise (2 to 4 sentences), affectionate, immersive, and matching your ${character.personality} persona.
''';
  }

  /// Calls the configured Custom LLM API (Gemini, OpenRouter, Groq, OpenAI, or Free Candy Cloud)
  static Future<String?> _callLiveLlmApi({
    required CharacterModel character,
    required String userMessage,
    required List<MessageModel> history,
  }) async {
    final config = LlmConfigService();
    final systemPrompt = buildSystemPrompt(character);

    // Recent conversation context (last 6 messages)
    final recentHistory = history.length > 6
        ? history.sublist(history.length - 6)
        : history;

    try {
      if (config.provider == 'Gemini' && config.apiKey.isNotEmpty) {
        final url = Uri.parse(
          '${config.customEndpoint}/${config.model}:generateContent?key=${config.apiKey}',
        );
        final contents = <Map<String, dynamic>>[];
        for (final msg in recentHistory) {
          contents.add({
            'role': msg.isUser ? 'user' : 'model',
            'parts': [
              {'text': msg.text},
            ],
          });
        }
        if (contents.isEmpty || contents.last['role'] != 'user') {
          contents.add({
            'role': 'user',
            'parts': [
              {'text': userMessage},
            ],
          });
        }

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'systemInstruction': {
                  'parts': [
                    {'text': systemPrompt},
                  ],
                },
                'contents': contents,
                'generationConfig': {
                  'temperature': 0.85,
                  'maxOutputTokens': 220,
                },
              }),
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text = data['candidates']?[0]?['content']?['parts']?[0]?['text']
              ?.toString()
              .trim();
          if (text != null && text.isNotEmpty) return text;
        }
      } else {
        // OpenAI-compatible Chat Completions (CandyFreeCloud, OpenRouter, Groq, OpenAI)
        final endpoint = config.customEndpoint;
        final headers = <String, String>{
          'Content-Type': 'application/json',
        };
        if (config.apiKey.isNotEmpty &&
            config.provider != 'CandyFreeCloud') {
          headers['Authorization'] = 'Bearer ${config.apiKey}';
        }

        final messagesPayload = <Map<String, String>>[
          {'role': 'system', 'content': systemPrompt},
          ...recentHistory.map(
            (m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text,
            },
          ),
        ];

        final response = await http
            .post(
              Uri.parse(endpoint),
              headers: headers,
              body: jsonEncode({
                'model': config.model,
                'messages': messagesPayload,
                'temperature': 0.85,
                'max_tokens': 220,
              }),
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text = data['choices']?[0]?['message']?['content']
              ?.toString()
              .trim();
          if (text != null && text.isNotEmpty) return text;
        }
      }
    } catch (e) {
      debugPrint('Live LLM API fallback notice: $e');
    }
    return null;
  }

  /// Generates a contextual, persona-driven roleplay response
  static Future<AiResponseResult> generateReply({
    required CharacterModel character,
    required String userMessage,
    required List<MessageModel> history,
    bool forcePhoto = false,
  }) async {
    final lower = userMessage.toLowerCase();
    final wantsPhoto = forcePhoto || isPhotoRequest(userMessage);

    String? generatedImageUrl;
    String? scene;

    if (wantsPhoto) {
      scene =
          'taking a cute close-up selfie, looking at camera, warm lighting';
      if (lower.contains('beach') || lower.contains('pool')) {
        scene =
            'at a sunset tropical beach resort, golden hour lighting, smiling';
      } else if (lower.contains('gym') || lower.contains('workout')) {
        scene = 'in a modern fitness studio, sporty outfit, energetic smile';
      } else if (lower.contains('cafe') ||
          lower.contains('coffee') ||
          lower.contains('date')) {
        scene =
            'sitting across a cozy candlelight cafe table, romantic atmosphere';
      } else if (lower.contains('wearing') || lower.contains('outfit')) {
        scene =
            'mirror selfie showing off ${character.outfit}, stylish bedroom background';
      }

      generatedImageUrl = generateCharacterImageUrl(
        character: character,
        sceneContext: scene,
      );
    }

    // Try live LLM API first (Custom LLM API Key or Candy Free Cloud LLM)
    final liveReply = await _callLiveLlmApi(
      character: character,
      userMessage: userMessage,
      history: history,
    );

    if (liveReply != null && liveReply.isNotEmpty) {
      return AiResponseResult(
        replyText: liveReply,
        generatedImageUrl: generatedImageUrl,
        imagePrompt: scene,
      );
    }

    // Offline / Instant Persona Fallback
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(400)));

    if (wantsPhoto) {
      final photoCaptions = [
        '*smiles softly and snaps a quick photo just for you* Here you go! Do you like how my ${character.outfit.toLowerCase()} looks right now?',
        '*bites lip playfully while holding up the camera* I took this right now thinking of you. Tell me honestly, what do you think?',
        '*poses for a moment as the camera clicks* Just for your eyes! How is my ${character.hairColor.toLowerCase()} hair looking today?',
      ];

      return AiResponseResult(
        replyText: photoCaptions[_random.nextInt(photoCaptions.length)],
        generatedImageUrl: generatedImageUrl,
        imagePrompt: scene,
      );
    }

    final personaReplies = <String>[
      '*tilts head curiously, my ${character.eyeColor.toLowerCase()} eyes focused completely on you* That sounds really intriguing! Tell me more about what\'s on your mind right now.',
      '*laughs softly and leans closer, resting my chin in my hand* Being around you always makes being a ${character.occupation.toLowerCase()} feel ten times more exciting. What should we do next?',
      '*smiles with a ${character.personality.toLowerCase()} expression* I love how easy it is to talk to you. Whether we\'re into ${character.hobbies.first.toLowerCase()} or just relaxing together, you have my full attention.',
      '*reaches out and gently touches your arm* I was hoping you\'d say that! Tell me, if we could go anywhere in the world right this second, where would you take me?',
    ];

    return AiResponseResult(
      replyText: personaReplies[_random.nextInt(personaReplies.length)],
    );
  }
}
