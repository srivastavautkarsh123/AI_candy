import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/llm_config_service.dart';

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  late String _selectedProvider;
  late TextEditingController _llmKeyController;
  late TextEditingController _llmModelController;
  late TextEditingController _llmEndpointController;

  // Firebase Project Controllers
  final TextEditingController _fbProjectIdController = TextEditingController();
  final TextEditingController _fbApiKeyController = TextEditingController();
  final TextEditingController _fbAppIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final llm = LlmConfigService();
    _selectedProvider = llm.provider;
    _llmKeyController = TextEditingController(text: llm.apiKey);
    _llmModelController = TextEditingController(text: llm.model);
    _llmEndpointController = TextEditingController(text: llm.customEndpoint);

    final fb = FirebaseService();
    if (fb.connectedProjectId != null) {
      _fbProjectIdController.text = fb.connectedProjectId!;
    }
  }

  @override
  void dispose() {
    _llmKeyController.dispose();
    _llmModelController.dispose();
    _llmEndpointController.dispose();
    _fbProjectIdController.dispose();
    _fbApiKeyController.dispose();
    _fbAppIdController.dispose();
    super.dispose();
  }

  void _onProviderChanged(String provider) {
    setState(() {
      _selectedProvider = provider;
      _llmModelController.text = LlmConfigService.defaultModelFor(provider);
      _llmEndpointController.text =
          LlmConfigService.defaultEndpointFor(provider);
    });
  }

  Future<void> _generateCustomCandyKey() async {
    final llm = context.read<LlmConfigService>();
    final newKey = await llm.generateNewCandyCloudKey();
    setState(() {
      _selectedProvider = 'CandyFreeCloud';
      _llmKeyController.text = newKey;
      _llmModelController.text = llm.model;
      _llmEndpointController.text = llm.customEndpoint;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔑 Generated new Custom LLM Key: $newKey'),
        backgroundColor: AppColors.primaryPink,
      ),
    );
  }

  Future<void> _saveLlmSettings() async {
    final llm = context.read<LlmConfigService>();
    await llm.saveConfig(
      provider: _selectedProvider,
      apiKey: _llmKeyController.text,
      model: _llmModelController.text,
      customEndpoint: _llmEndpointController.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Custom LLM API Key & Model saved!'),
        backgroundColor: AppColors.onlineGreen,
      ),
    );
  }

  Future<void> _connectFirebaseProject() async {
    if (_fbProjectIdController.text.trim().isEmpty ||
        _fbApiKeyController.text.trim().isEmpty ||
        _fbAppIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your Firebase Project ID, API Key, and App ID.',
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final fb = context.read<FirebaseService>();
    final ok = await fb.configureAndConnect(
      projectId: _fbProjectIdController.text,
      apiKey: _fbApiKeyController.text,
      appId: _fbAppIdController.text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '🔥 Firebase Project (${_fbProjectIdController.text}) Connected!'
              : '⚠️ Firebase Error: ${fb.lastError}',
        ),
        backgroundColor: ok ? AppColors.onlineGreen : AppColors.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fb = context.watch<FirebaseService>();
    final providers = [
      'CandyFreeCloud',
      'Gemini',
      'OpenRouter',
      'Groq',
      'OpenAI',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase & Custom LLM API'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Custom LLM API Key Generator & Configuration Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
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
                        Icons.key_rounded,
                        color: AppColors.primaryPink,
                        size: 26,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Custom LLM API Key Studio',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Generate a free Candy Cloud LLM key for live AI roleplay, or connect your own Gemini, OpenRouter, Groq, or OpenAI key.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Provider Selector Chips
                  const Text(
                    'Select LLM Provider',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: providers.map((p) {
                      final isSelected = _selectedProvider == p;
                      return ChoiceChip(
                        label: Text(
                          p == 'CandyFreeCloud' ? 'Candy Free Cloud ✨' : p,
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primaryPink,
                        backgroundColor: AppColors.surfaceLight,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                        onSelected: (_) => _onProviderChanged(p),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // API Key Input + Copy & Generate Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'API Key',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _generateCustomCandyKey,
                        icon: const Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: AppColors.accentGold,
                        ),
                        label: const Text(
                          'Create New Free Key',
                          style: TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _llmKeyController,
                    decoration: InputDecoration(
                      hintText: 'Paste API key or click Create New Free Key',
                      suffixIcon: IconButton(
                        tooltip: 'Copy API Key',
                        icon: const Icon(Icons.copy_rounded, size: 19),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: _llmKeyController.text),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('API Key copied to clipboard!'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Model Name',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _llmModelController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. gemini-2.5-flash or deepseek/deepseek-chat:free',
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _saveLlmSettings,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text(
                        'Save LLM API Configuration',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Firebase Project Connection Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.accentGold,
                            size: 26,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Firebase Cloud Connection',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
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
                          color: fb.isConnected
                              ? AppColors.onlineGreen.withValues(alpha: 0.18)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          fb.isConnected ? 'CONNECTED' : 'LOCAL HYBRID',
                          style: TextStyle(
                            color: fb.isConnected
                                ? AppColors.onlineGreen
                                : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your Firebase project credentials from Firebase Console → Project Settings to sync Auth & Firestore in the cloud.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _fbProjectIdController,
                    decoration: const InputDecoration(
                      labelText: 'Firebase Project ID',
                      hintText: 'e.g. candy-ai-prod',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _fbApiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Firebase Web / App API Key',
                      hintText: 'AIzaSy...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _fbAppIdController,
                    decoration: const InputDecoration(
                      labelText: 'Firebase App ID',
                      hintText: '1:1234567890:web:abcdef123456',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _connectFirebaseProject,
                      icon: const Icon(Icons.cloud_done_rounded),
                      label: const Text(
                        'Connect Firebase Project',
                        style: TextStyle(fontWeight: FontWeight.w800),
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
