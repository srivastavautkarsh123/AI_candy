import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/tts_service.dart';
import '../../models/character_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../character/character_detail_screen.dart';
import '../payment/subscription_screen.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final CharacterModel character;

  const ChatScreen({super.key, required this.character});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _quickPrompts = [
    '📸 Send me a selfie!',
    '👗 What are you wearing right now?',
    '🤫 Tell me a secret...',
    '🍷 Let\'s go on a romantic date tonight',
  ];

  @override
  void dispose() {
    TtsService().stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend({String? presetText, bool forcePhoto = false}) async {
    final text = presetText ?? _textController.text;
    if (text.trim().isEmpty && !forcePhoto) return;

    final authVm = context.read<AuthViewModel>();
    final tokenCost = forcePhoto ? 5 : 1;
    final hasTokens = await authVm.spendTokens(tokenCost);

    if (!hasTokens) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not enough Candy Tokens! Claim free tokens now.'),
          action: SnackBarAction(
            label: 'Get Free Tokens',
            textColor: AppColors.accentGold,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
          ),
        ),
      );
      return;
    }

    if (presetText == null) {
      _textController.clear();
    }

    if (!mounted) return;
    final chatVm = context.read<ChatViewModel>();
    _scrollToBottom();
    await chatVm.sendMessage(
      character: widget.character,
      text: text,
      forcePhoto: forcePhoto,
    );
    _scrollToBottom();
  }

  void _showPhotoRequestSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final scenes = [
          ('📸 Close-up Cute Selfie', 'Send me a close-up cute selfie!'),
          ('🪞 Bedroom Mirror Outfit Check', 'Show me what you are wearing in the mirror!'),
          ('🏖️ Sunset Beach Pose', 'Send me a photo at the sunset beach!'),
          ('☕ Cozy Candlelight Date', 'Send a photo from our cozy cafe date!'),
          ('🏋️‍♀️ Sporty Gym Workout', 'Send me a photo from your workout session!'),
        ];

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.camera_enhance_rounded,
                        color: AppColors.primaryPink,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ask ${widget.character.name} for a Photo',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '5 Tokens',
                      style: TextStyle(
                        color: AppColors.primaryPink,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Generates an AI photo matching their appearance & outfit:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              ...scenes.map(
                (scene) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(
                    scene.$1,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: AppColors.primaryPink,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleSend(presetText: scene.$2, forcePhoto: true);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatVm = context.watch<ChatViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final messages = chatVm.getMessagesFor(widget.character);
    final isTyping = chatVm.isTyping(widget.character.id);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CharacterDetailScreen(character: widget.character),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.character.avatarUrl),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppColors.onlineGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.character.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.character.relationship} • ${widget.character.style}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryPink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Token Balance Pill
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.accentGold,
                    size: 16,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    authVm.currentUser?.isPro == true
                        ? 'PRO'
                        : '${authVm.currentUser?.tokens ?? 0}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            color: AppColors.surfaceLight,
            onSelected: (val) {
              if (val == 'reset') {
                chatVm.clearConversation(widget.character);
              } else if (val == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CharacterDetailScreen(character: widget.character),
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'profile',
                child: Text('View Character Profile'),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Text('Reset Chat Memory'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isTyping) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              NetworkImage(widget.character.avatarUrl),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            '${widget.character.name} is typing...',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return MessageBubble(
                  message: messages[index],
                  character: widget.character,
                );
              },
            ),
          ),

          // Quick Roleplay Suggestion Chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final prompt = _quickPrompts[i];
                return ActionChip(
                  backgroundColor: AppColors.surfaceLight,
                  side: const BorderSide(color: AppColors.cardBorder),
                  label: Text(
                    prompt,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () {
                    final isSelfie = i == 0;
                    _handleSend(presetText: prompt, forcePhoto: isSelfie);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Input Bar with AI Photo Request Camera Button
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.cardBorder, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Request AI Selfie Button
                  InkWell(
                    onTap: _showPhotoRequestSheet,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primaryPink.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.primaryPink,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _handleSend(),
                      decoration: InputDecoration(
                        hintText:
                            'Message ${widget.character.name}... (use * for actions)',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => _handleSend(),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
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
