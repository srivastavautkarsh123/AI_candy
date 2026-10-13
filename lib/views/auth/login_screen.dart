import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showEmailForm = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final authVm = context.read<AuthViewModel>();
    final success = await authVm.signInWithGoogle();
    if (!mounted) return;

    if (!success && authVm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In Notice: ${authVm.errorMessage}'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _handleOAuth(String provider) async {
    final authVm = context.read<AuthViewModel>();
    await authVm.signInWithThirdParty(
      providerName: provider,
      customName: _nameController.text,
      customEmail: _emailController.text,
      customPassword: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          // Ambient glowing background circles
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryPink.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondaryPurple.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Candy AI Glowing Badge Logo
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPink.withValues(alpha: 0.45),
                              blurRadius: 28,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 22),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                          children: [
                            TextSpan(
                              text: 'Candy',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: '.ai',
                              style: TextStyle(color: AppColors.primaryPink),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Create, customize & chat with lifelike AI companions.\nGenerate private selfies and voice messages.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Free Welcome Bonus Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.primaryPink.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              color: AppColors.accentGold,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'FREE 150 Candy Tokens on Instant Sign-In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Third-Party OAuth Buttons
                      _OAuthButton(
                        icon: Icons.g_mobiledata_rounded,
                        iconColor: Colors.white,
                        backgroundColor: AppColors.primaryPink,
                        isGradient: true,
                        label: 'Continue with Google (Free)',
                        isLoading: authVm.isLoading,
                        onTap: _handleGoogleSignIn,
                      ),
                      const SizedBox(height: 12),
                      _OAuthButton(
                        icon: Icons.discord_rounded,
                        iconColor: const Color(0xFF5865F2),
                        backgroundColor: AppColors.surfaceLight,
                        label: 'Continue with Discord',
                        isLoading: authVm.isLoading,
                        onTap: () => _handleOAuth('Discord'),
                      ),
                      const SizedBox(height: 12),
                      _OAuthButton(
                        icon: Icons.apple_rounded,
                        iconColor: Colors.white,
                        backgroundColor: AppColors.surfaceLight,
                        label: 'Continue with Apple',
                        isLoading: authVm.isLoading,
                        onTap: () => _handleOAuth('Apple'),
                      ),
                      const SizedBox(height: 18),

                      // Optional Custom Profile Sign-In
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _showEmailForm = !_showEmailForm);
                        },
                        icon: Icon(
                          _showEmailForm
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.email_outlined,
                          color: AppColors.textSecondary,
                        ),
                        label: Text(
                          _showEmailForm
                              ? 'Hide Email Sign-In Form'
                              : 'Or Sign In with Email & Password',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),

                      if (_showEmailForm) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Your Display Name (Optional)',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Password (min 6 characters)',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: authVm.isLoading
                                ? null
                                : () => _handleOAuth('Email'),
                            child: const Text(
                              'Sign In / Register with Email',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),
                      const Text(
                        '18+ Only • All characters are AI-generated personas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool isGradient;
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _OAuthButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.isGradient = false,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            gradient: isGradient ? AppColors.primaryGradient : null,
            color: isGradient ? null : backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: isGradient
                ? null
                : Border.all(color: AppColors.cardBorder, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              else ...[
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
