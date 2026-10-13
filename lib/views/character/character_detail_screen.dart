import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/tts_service.dart';
import '../../models/character_model.dart';
import '../../viewmodels/character_viewmodel.dart';
import '../chat/chat_screen.dart';

class CharacterDetailScreen extends StatefulWidget {
  final CharacterModel character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  int _currentGalleryIndex = 0;

  @override
  void dispose() {
    TtsService().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charVm = context.watch<CharacterViewModel>();
    final character = charVm.getById(widget.character.id) ?? widget.character;
    final gallery = character.galleryUrls.isNotEmpty
        ? character.galleryUrls
        : [character.avatarUrl];
    final tts = TtsService();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Photo Carousel SliverAppBar
          SliverAppBar(
            expandedHeight: 440,
            pinned: true,
            backgroundColor: AppColors.background,
            actions: [
              IconButton(
                onPressed: () => charVm.toggleFavorite(character.id),
                icon: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(
                    character.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: character.isFavorite
                        ? AppColors.primaryPink
                        : Colors.white,
                  ),
                ),
              ),
              if (character.isCustom)
                IconButton(
                  onPressed: () async {
                    await charVm.deleteCustomCharacter(character.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.errorRed,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: gallery.length,
                    onPageChanged: (idx) =>
                        setState(() => _currentGalleryIndex = idx),
                    itemBuilder: (context, index) {
                      return Image.network(
                        gallery[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: AppColors.textMuted,
                          ),
                        ),
                      );
                    },
                  ),
                  // Bottom Gradient Overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.darkCardGradient,
                    ),
                  ),
                  // Gallery Dots Indicator
                  if (gallery.length > 1)
                    Positioned(
                      bottom: 95,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          gallery.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentGalleryIndex == i ? 22 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _currentGalleryIndex == i
                                  ? AppColors.primaryPink
                                  : Colors.white38,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Name & Headline Overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                character.style.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.onlineGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Online • ${character.messagesCount} chats',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${character.name}, ${character.age}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          character.tagline,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Character Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Voice Sample Button
                  ValueListenableBuilder<String?>(
                    valueListenable: tts.activeMessageNotifier,
                    builder: (context, activeId, _) {
                      final sampleId = 'voice_sample_${character.id}';
                      final isPlaying = activeId == sampleId;
                      return InkWell(
                        onTap: () => tts.speak(
                          messageId: sampleId,
                          text: character.greeting,
                          pitch: character.voicePitch,
                          rate: character.voiceRate,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isPlaying
                                  ? AppColors.primaryPink
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPink
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.stop_rounded
                                      : Icons.graphic_eq_rounded,
                                  color: AppColors.primaryPink,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isPlaying
                                          ? 'Playing Voice Sample...'
                                          : 'Listen to ${character.name}\'s Voice',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                    Text(
                                      'Voice Tone: ${character.voiceStyle}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isPlaying
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_fill_rounded,
                                color: AppColors.primaryPink,
                                size: 32,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),

                  const Text(
                    'About & Backstory',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    character.bio,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.5,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Character Attributes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.5,
                    children: [
                      _TraitTile(
                        label: 'Personality',
                        value: character.personality,
                        icon: Icons.psychology_outlined,
                      ),
                      _TraitTile(
                        label: 'Relationship',
                        value: character.relationship,
                        icon: Icons.favorite_outline_rounded,
                      ),
                      _TraitTile(
                        label: 'Occupation',
                        value: character.occupation,
                        icon: Icons.work_outline_rounded,
                      ),
                      _TraitTile(
                        label: 'Ethnicity',
                        value: character.ethnicity,
                        icon: Icons.public_rounded,
                      ),
                      _TraitTile(
                        label: 'Hair',
                        value: '${character.hairColor} • ${character.hairStyle}',
                        icon: Icons.face_retouching_natural_rounded,
                      ),
                      _TraitTile(
                        label: 'Eyes & Body',
                        value: '${character.eyeColor} • ${character.bodyType}',
                        icon: Icons.remove_red_eye_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  const Text(
                    'Hobbies & Interests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: character.hobbies
                        .map(
                          (hobby) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Text(
                              hobby,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(character: character),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_rounded),
            label: Text(
              'Chat with ${character.name} Now',
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TraitTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TraitTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryPink, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
