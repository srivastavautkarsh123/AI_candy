import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/character_viewmodel.dart';
import '../chat/chat_screen.dart';

class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  int _currentStep = 0;

  // Step 1: Style & Gender
  String _style = 'Realistic';
  String _gender = 'Female';

  // Step 2: Physical Appearance
  String _ethnicity = 'Caucasian';
  String _eyeColor = 'Emerald Green';
  String _hairStyle = 'Long Wavy';
  String _hairColor = 'Honey Blonde';
  String _bodyType = 'Hourglass';
  String _outfit = 'Silk Evening Dress';

  // Step 3: Personality & Roleplay
  String _personality = 'Playful & Flirty';
  String _occupation = 'Fashion Model';
  String _relationship = 'Girlfriend';
  String _voiceStyle = 'Sultry & Playful';
  final Set<String> _selectedHobbies = {'Photography', 'Midnight Drives'};

  // Step 4: Identity
  final TextEditingController _nameController =
      TextEditingController(text: 'Chloe');
  final TextEditingController _bioController = TextEditingController();
  double _age = 22;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submitCharacter() async {
    final name = _nameController.text.trim().isEmpty
        ? 'Nova'
        : _nameController.text.trim();

    final charVm = context.read<CharacterViewModel>();
    final created = await charVm.createCustomCharacter(
      name: name,
      age: _age.round(),
      style: _style,
      gender: _gender,
      ethnicity: _ethnicity,
      eyeColor: _eyeColor,
      hairStyle: _hairStyle,
      hairColor: _hairColor,
      bodyType: _bodyType,
      outfit: _outfit,
      personality: _personality,
      occupation: _occupation,
      relationship: _relationship,
      hobbies: _selectedHobbies.toList(),
      voiceStyle: _voiceStyle,
      customBio: _bioController.text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ ${created.name} has been brought to life!'),
        backgroundColor: AppColors.primaryPink,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(character: created),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final charVm = context.watch<CharacterViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your AI Companion'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: List.generate(4, (index) {
                final isActive = index <= _currentStep;
                return Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      gradient: isActive ? AppColors.primaryGradient : null,
                      color: isActive ? null : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: charVm.isGeneratingCharacter
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPink.withValues(alpha: 0.4),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Synthesizing Your AI Companion...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rendering $_style portrait • $_hairColor $_hairStyle hair • $_outfit',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildCurrentStepContent(),
                  ),
                ),
                // Bottom Navigation Buttons
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_currentStep > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(color: AppColors.cardBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () =>
                                setState(() => _currentStep -= 1),
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            if (_currentStep < 3) {
                              setState(() => _currentStep += 1);
                            } else {
                              _submitCharacter();
                            }
                          },
                          icon: Icon(
                            _currentStep < 3
                                ? Icons.arrow_forward_rounded
                                : Icons.auto_awesome_rounded,
                          ),
                          label: Text(
                            _currentStep < 3
                                ? 'Next Step (${_currentStep + 1}/4)'
                                : 'Bring My AI to Life ✨',
                            style: const TextStyle(
                              fontSize: 15.5,
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
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1StyleAndGender();
      case 1:
        return _buildStep2Appearance();
      case 2:
        return _buildStep3Personality();
      default:
        return _buildStep4Identity();
    }
  }

  Widget _buildStep1StyleAndGender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1: Choose Art Style & Gender',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select how your AI companion will look in portraits and chat selfies.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _VisualStyleCard(
                title: 'Realistic',
                subtitle: 'Photorealistic 8K portraits',
                imageUrl:
                    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600&auto=format&fit=crop&q=80',
                isSelected: _style == 'Realistic',
                onTap: () => setState(() => _style = 'Realistic'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _VisualStyleCard(
                title: 'Anime',
                subtitle: 'Vibrant studio anime art',
                imageUrl:
                    'https://image.pollinations.ai/prompt/masterpiece%20anime%20girl%20portrait%2C%20pastel%20pink%20twintails%20hair%2C%20glowing%20violet%20eyes%2C%20oversized%20cyberpunk%20hoodie?width=500&height=700&seed=402&nologo=true',
                isSelected: _style == 'Anime',
                onTap: () => setState(() => _style = 'Anime'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          'Select Gender',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        _buildChoiceWrap(
          options: const ['Female', 'Male', 'Non-Binary'],
          selected: _gender,
          onSelected: (val) => setState(() => _gender = val),
        ),
      ],
    );
  }

  Widget _buildStep2Appearance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 2: Customize Physical Appearance',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Every trait you pick shapes your AI\'s generated photos and selfies.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Ethnicity / Heritage'),
        _buildChoiceWrap(
          options: const [
            'Caucasian',
            'Latina',
            'Japanese',
            'Korean',
            'Mediterranean',
            'Ebony',
            'Fantasy Elven',
          ],
          selected: _ethnicity,
          onSelected: (v) => setState(() => _ethnicity = v),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Hair Style'),
        _buildChoiceWrap(
          options: const [
            'Long Wavy',
            'Long Straight',
            'High Ponytail',
            'Twin Tails',
            'Bob Cut',
            'Sleek Updo',
            'Textured Waves',
          ],
          selected: _hairStyle,
          onSelected: (v) => setState(() => _hairStyle = v),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Hair Color'),
        _buildChoiceWrap(
          options: const [
            'Honey Blonde',
            'Platinum Blonde',
            'Jet Black',
            'Dark Brunette',
            'Pastel Pink',
            'Silver White',
            'Crimson Red',
          ],
          selected: _hairColor,
          onSelected: (v) => setState(() => _hairColor = v),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Eye Color'),
        _buildChoiceWrap(
          options: const [
            'Emerald Green',
            'Ice Blue',
            'Warm Brown',
            'Violet',
            'Hazel',
            'Crimson Red',
          ],
          selected: _eyeColor,
          onSelected: (v) => setState(() => _eyeColor = v),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Body Type'),
        _buildChoiceWrap(
          options: const [
            'Petite',
            'Slender & Elegant',
            'Hourglass',
            'Athletic & Curvy',
            'Muscular & Athletic',
          ],
          selected: _bodyType,
          onSelected: (v) => setState(() => _bodyType = v),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Signature Outfit'),
        _buildChoiceWrap(
          options: const [
            'Silk Evening Dress',
            'Fitted Gym Sportswear',
            'Oversized Cyberpunk Hoodie',
            'Tailored Silk Blazer',
            'Summer Sundress',
            'Royal Velvet Corset Gown',
            'Casual Streetwear',
          ],
          selected: _outfit,
          onSelected: (v) => setState(() => _outfit = v),
        ),
      ],
    );
  }

  Widget _buildStep3Personality() {
    const allHobbies = [
      'Photography',
      'Midnight Drives',
      'Gaming',
      'Anime',
      'Fitness',
      'Wine Tasting',
      'Cooking',
      'Cosplay',
      'Stargazing',
      'Salsa Dancing',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 3: Personality & Relationship',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Define how your AI companion talks, flirts, and interacts with you.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Personality Archetype'),
        _buildChoiceWrap(
          options: const [
            'Playful & Flirty',
            'Sweet & Shy',
            'Confident & Passionate',
            'Mysterious & Devoted',
            'Dominant & Intellectual',
            'Caring & Romantic',
          ],
          selected: _personality,
          onSelected: (v) => setState(() => _personality = v),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Relationship Dynamic'),
        _buildChoiceWrap(
          options: const [
            'Girlfriend',
            'Boyfriend',
            'Secret Crush',
            'Romantic Partner',
            'Boss & Lover',
            'Fated Soulmate',
            'Best Friend',
          ],
          selected: _relationship,
          onSelected: (v) => setState(() => _relationship = v),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Occupation / Role'),
        _buildChoiceWrap(
          options: const [
            'Fashion Model',
            'Pro Streamer',
            'Fitness Trainer',
            'Tech CEO',
            'College Student',
            'Archmage',
            'Nurse',
            'Luxury Architect',
          ],
          selected: _occupation,
          onSelected: (v) => setState(() => _occupation = v),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Voice Tone'),
        _buildChoiceWrap(
          options: const [
            'Sultry & Playful',
            'Soft & Cute',
            'Energetic & Warm',
            'Velvety & Calm',
            'Confident & Smooth',
          ],
          selected: _voiceStyle,
          onSelected: (v) => setState(() => _voiceStyle = v),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Hobbies (Select up to 4)'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allHobbies.map((hobby) {
            final isSelected = _selectedHobbies.contains(hobby);
            return FilterChip(
              selected: isSelected,
              selectedColor: AppColors.primaryPink.withValues(alpha: 0.25),
              checkmarkColor: AppColors.primaryPink,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.primaryPink : AppColors.cardBorder,
              ),
              label: Text(
                hobby,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              onSelected: (val) {
                setState(() {
                  if (val && _selectedHobbies.length < 4) {
                    _selectedHobbies.add(hobby);
                  } else {
                    _selectedHobbies.remove(hobby);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep4Identity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 4: Name & Final Summary',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Give your AI companion a name and optional custom scenario.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Character Name'),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Enter character name (e.g. Chloe, Luna, Kai)',
            prefixIcon: Icon(Icons.auto_awesome_outlined, color: AppColors.primaryPink),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Character Age (18+)'),
            Text(
              '${_age.round()} years old',
              style: const TextStyle(
                color: AppColors.primaryPink,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Slider(
          value: _age,
          min: 18,
          max: 40,
          divisions: 22,
          activeColor: AppColors.primaryPink,
          onChanged: (val) => setState(() => _age = val),
        ),
        const SizedBox(height: 14),
        _buildSectionTitle('Custom Backstory / Scenario (Optional)'),
        TextField(
          controller: _bioController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText:
                'Leave blank to auto-generate, or describe how you two met...',
          ),
        ),
        const SizedBox(height: 24),
        // Summary Preview Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryPink.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primaryPink, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Blueprint Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '• Style: $_style $_gender (${_age.round()} yrs)\n'
                '• Look: $_ethnicity, $_hairColor $_hairStyle hair, $_eyeColor eyes, $_bodyType\n'
                '• Outfit: $_outfit\n'
                '• Persona: $_personality $_occupation • Your $_relationship\n'
                '• Voice: $_voiceStyle',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.55,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildChoiceWrap({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return ChoiceChip(
          label: Text(opt),
          selected: isSelected,
          selectedColor: AppColors.primaryPink,
          backgroundColor: AppColors.surface,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primaryPink : AppColors.cardBorder,
          ),
          onSelected: (_) => onSelected(opt),
        );
      }).toList(),
    );
  }
}

class _VisualStyleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _VisualStyleCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryPink : AppColors.cardBorder,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.35),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: AppColors.surface),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.darkCardGradient,
                ),
              ),
              if (isSelected)
                const Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primaryPink,
                    child: Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
