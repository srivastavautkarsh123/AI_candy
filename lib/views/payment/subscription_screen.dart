import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final user = authVm.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candy Tokens & Pro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'YOUR CANDY BALANCE',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.isPro == true ? 'CANDY PRO' : 'FREE TIER',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.accentGold,
                        size: 36,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user?.isPro == true ? 'UNLIMITED' : '${user?.tokens ?? 0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tokens',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        await authVm.addFreeTokens(50);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 +50 Free Candy Tokens added!'),
                              backgroundColor: AppColors.primaryPink,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.card_giftcard_rounded, size: 20),
                      label: const Text(
                        'Claim +50 Free Daily Tokens',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'How Tokens Work',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const _TokenUsageRow(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'AI Roleplay Messages',
              cost: '1 Token / message',
            ),
            const _TokenUsageRow(
              icon: Icons.camera_alt_outlined,
              title: 'Request AI Character Selfie / Photo',
              cost: '5 Tokens / photo',
            ),
            const _TokenUsageRow(
              icon: Icons.person_add_alt_1_outlined,
              title: 'Create New Custom AI Character',
              cost: 'FREE',
            ),
            const _TokenUsageRow(
              icon: Icons.volume_up_outlined,
              title: 'AI Voice Playback (TTS)',
              cost: 'FREE',
            ),
            const SizedBox(height: 28),

            // Candy Pro Upgrade Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primaryPink.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.accentGold,
                        size: 28,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Candy.ai PRO Pass',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '• Unlimited AI Roleplay Messages\n'
                    '• Unlimited Custom AI Selfies & Outfits\n'
                    '• Unlimited Custom Character Slots\n'
                    '• Faster AI Image Generation Priority',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: user?.isPro == true
                          ? null
                          : () async {
                              await authVm.upgradeToPro();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '✨ Welcome to Candy.ai PRO! Unlimited access unlocked.',
                                    ),
                                    backgroundColor: AppColors.secondaryPurple,
                                  ),
                                );
                              }
                            },
                      child: Text(
                        user?.isPro == true
                            ? 'Candy Pro Active ✓'
                            : 'Activate Free Demo Pro Pass',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenUsageRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String cost;

  const _TokenUsageRow({
    required this.icon,
    required this.title,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryPink, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            cost,
            style: const TextStyle(
              color: AppColors.accentGold,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
