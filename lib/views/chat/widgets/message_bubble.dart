import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/tts_service.dart';
import '../../../models/character_model.dart';
import '../../../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final CharacterModel character;

  const MessageBubble({
    super.key,
    required this.message,
    required this.character,
  });

  /// Parses *roleplay actions* vs normal dialogue for rich Candy AI styling
  List<TextSpan> _buildFormattedSpans(String rawText, bool isUser) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*([^*]+)\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(rawText)) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: rawText.substring(lastEnd, match.start),
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.42,
              fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: '*${match.group(1)}* ',
          style: TextStyle(
            color: isUser
                ? Colors.white.withValues(alpha: 0.85)
                : const Color(0xFFFF94C2),
            fontStyle: FontStyle.italic,
            fontSize: 14.5,
            height: 1.42,
          ),
        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < rawText.length) {
      spans.add(
        TextSpan(
          text: rawText.substring(lastEnd),
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.42,
            fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      );
    }

    return spans;
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Container(
                    height: 300,
                    color: AppColors.surface,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final timeStr = DateFormat('h:mm a').format(message.timestamp);
    final tts = TtsService();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceLight,
              backgroundImage: NetworkImage(character.avatarUrl),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isUser ? AppColors.primaryGradient : null,
                color: isUser ? null : AppColors.surfaceLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.cardBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageUrl != null &&
                      message.imageUrl!.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () =>
                          _showFullScreenImage(context, message.imageUrl!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Image.network(
                              message.imageUrl!,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 250,
                                  width: double.infinity,
                                  color: AppColors.surface,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: AppColors.primaryPink,
                                        strokeWidth: 2.5,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Generating AI Photo...',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              errorBuilder: (_, _, _) => Image.network(
                                character.avatarUrl,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: AppColors.primaryPink,
                                    size: 13,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'AI Photo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  RichText(
                    text: TextSpan(
                      children: _buildFormattedSpans(message.text, isUser),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: isUser ? Colors.white70 : AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      if (!isUser) ...[
                        const SizedBox(width: 12),
                        ValueListenableBuilder<String?>(
                          valueListenable: tts.activeMessageNotifier,
                          builder: (context, activeId, _) {
                            final isPlaying = activeId == message.id;
                            return InkWell(
                              onTap: () => tts.speak(
                                messageId: message.id,
                                text: message.text,
                                pitch: character.voicePitch,
                                rate: character.voiceRate,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPlaying
                                          ? Icons.stop_circle_rounded
                                          : Icons.volume_up_rounded,
                                      size: 16,
                                      color: isPlaying
                                          ? AppColors.primaryPink
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isPlaying ? 'Stop' : 'Voice',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isPlaying
                                            ? AppColors.primaryPink
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
