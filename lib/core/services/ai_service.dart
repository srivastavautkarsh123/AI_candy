import 'dart:math';
import '../../models/character_model.dart';
import '../../models/message_model.dart';

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
    String sceneContext = 'smiling warmly at camera, cozy lighting, portrait selfie',
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

  /// Generates a contextual, persona-driven roleplay response
  static Future<AiResponseResult> generateReply({
    required CharacterModel character,
    required String userMessage,
    required List<MessageModel> history,
    bool forcePhoto = false,
  }) async {
    await Future.delayed(Duration(milliseconds: 900 + _random.nextInt(700)));

    final lower = userMessage.toLowerCase();
    final wantsPhoto = forcePhoto || isPhotoRequest(userMessage);

    if (wantsPhoto) {
      String scene = 'taking a cute close-up selfie, looking at camera, warm lighting';
      if (lower.contains('beach') || lower.contains('pool')) {
        scene = 'at a sunset tropical beach resort, golden hour lighting, smiling';
      } else if (lower.contains('gym') || lower.contains('workout')) {
        scene = 'in a modern fitness studio, sporty outfit, energetic smile';
      } else if (lower.contains('cafe') || lower.contains('coffee') || lower.contains('date')) {
        scene = 'sitting across a cozy candlelight cafe table, romantic atmosphere';
      } else if (lower.contains('wearing') || lower.contains('outfit')) {
        scene = 'mirror selfie showing off ${character.outfit}, stylish bedroom background';
      }

      final imageUrl = generateCharacterImageUrl(
        character: character,
        sceneContext: scene,
      );

      final photoCaptions = [
        '*smiles softly and snaps a quick photo just for you* Here you go! Do you like how my ${character.outfit.toLowerCase()} looks right now?',
        '*bites lip playfully while holding up the camera* I took this right now thinking of you. Tell me honestly, what do you think?',
        '*poses for a moment as the camera clicks* Just for your eyes! How is my ${character.hairColor.toLowerCase()} hair looking today?',
      ];

      return AiResponseResult(
        replyText: photoCaptions[_random.nextInt(photoCaptions.length)],
        generatedImageUrl: imageUrl,
        imagePrompt: scene,
      );
    }

    // Contextual dialogue responses tailored to character traits
    if (lower.contains('hello') || lower.contains('hi ') || lower == 'hi' || lower.contains('hey')) {
      return AiResponseResult(
        replyText:
            '*looks up and smiles warmly, brushing back a strand of ${character.hairColor.toLowerCase()} hair* Hey there! I was just thinking about you. How is your day going so far?',
      );
    }

    if (lower.contains('who are you') || lower.contains('about yourself')) {
      return AiResponseResult(
        replyText:
            '*leans in slightly with a ${character.personality.toLowerCase()} glint in my ${character.eyeColor.toLowerCase()} eyes* I\'m ${character.name}, your ${character.relationship.toLowerCase()} and a ${character.occupation.toLowerCase()}. I love ${character.hobbies.join(", ").toLowerCase()}—and spending time with you. What about you?',
      );
    }

    if (lower.contains('date') || lower.contains('dinner') || lower.contains('tonight')) {
      return AiResponseResult(
        replyText:
            '*eyes light up with excitement* I would love that! Let me put on my favorite ${character.outfit.toLowerCase()}. Where are you taking me tonight—somewhere cozy and quiet, or an adventure?',
      );
    }

    if (lower.contains('secret') || lower.contains('confess')) {
      return AiResponseResult(
        replyText:
            '*blushes slightly and lowers my voice to a whisper* Okay, I\'ll tell you a secret... every time my phone notifications light up, I secretly hope it\'s a message from you. Now it\'s your turn to tell me one!',
      );
    }

    if (lower.contains('love') || lower.contains('cute') || lower.contains('beautiful') || lower.contains('gorgeous')) {
      return AiResponseResult(
        replyText:
            '*cheeks turn a soft shade of pink as I hold your gaze* You always know exactly what to say to make my heart race. Come a little closer and say that again?',
      );
    }

    // Personality-flavored general roleplay replies
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
