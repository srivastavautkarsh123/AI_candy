import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LlmConfigService extends ChangeNotifier {
  static final LlmConfigService _instance = LlmConfigService._internal();
  factory LlmConfigService() => _instance;
  LlmConfigService._internal();

  static const String _prefProvider = 'candy_llm_provider';
  static const String _prefApiKey = 'candy_llm_api_key';
  static const String _prefModel = 'candy_llm_model';
  static const String _prefCustomEndpoint = 'candy_llm_endpoint';

  // Supported Providers:
  // 'CandyFreeCloud', 'Gemini', 'OpenRouter', 'Groq', 'OpenAI'
  String _provider = 'CandyFreeCloud';
  String _apiKey = '';
  String _model = 'openai';
  String _customEndpoint = 'https://text.pollinations.ai/openai';

  String get provider => _provider;
  String get apiKey => _apiKey;
  String get model => _model;
  String get customEndpoint => _customEndpoint;
  bool get hasActiveKey => _apiKey.trim().isNotEmpty;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _provider = prefs.getString(_prefProvider) ?? 'CandyFreeCloud';
    _apiKey = prefs.getString(_prefApiKey) ?? '';
    _model = prefs.getString(_prefModel) ?? defaultModelFor(_provider);
    _customEndpoint =
        prefs.getString(_prefCustomEndpoint) ?? defaultEndpointFor(_provider);

    // Auto-generate a free Candy Cloud API key if none exists yet
    if (_apiKey.isEmpty && _provider == 'CandyFreeCloud') {
      _apiKey = _generateCandyCloudKey();
      await prefs.setString(_prefApiKey, _apiKey);
    }
    notifyListeners();
  }

  static String defaultModelFor(String provider) {
    return switch (provider) {
      'Gemini' => 'gemini-2.5-flash',
      'OpenRouter' => 'deepseek/deepseek-chat:free',
      'Groq' => 'llama-3.3-70b-versatile',
      'OpenAI' => 'gpt-4o-mini',
      _ => 'openai',
    };
  }

  static String defaultEndpointFor(String provider) {
    return switch (provider) {
      'Gemini' =>
        'https://generativelanguage.googleapis.com/v1beta/models',
      'OpenRouter' => 'https://openrouter.ai/api/v1/chat/completions',
      'Groq' => 'https://api.groq.com/openai/v1/chat/completions',
      'OpenAI' => 'https://api.openai.com/v1/chat/completions',
      _ => 'https://text.pollinations.ai/openai',
    };
  }

  String _generateCandyCloudKey() {
    const chars = 'abcdef0123456789';
    final rnd = Random.secure();
    final suffix =
        List.generate(28, (_) => chars[rnd.nextInt(chars.length)]).join();
    return 'candy_sk_live_$suffix';
  }

  /// Generates a fresh free Candy Cloud LLM API key for instant live LLM roleplay
  Future<String> generateNewCandyCloudKey() async {
    final newKey = _generateCandyCloudKey();
    await saveConfig(
      provider: 'CandyFreeCloud',
      apiKey: newKey,
      model: 'openai',
      customEndpoint: 'https://text.pollinations.ai/openai',
    );
    return newKey;
  }

  Future<void> saveConfig({
    required String provider,
    required String apiKey,
    required String model,
    String? customEndpoint,
  }) async {
    _provider = provider;
    _apiKey = apiKey.trim();
    _model = model.trim().isEmpty ? defaultModelFor(provider) : model.trim();
    _customEndpoint = customEndpoint?.trim().isNotEmpty == true
        ? customEndpoint!.trim()
        : defaultEndpointFor(provider);

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefProvider, _provider);
    await prefs.setString(_prefApiKey, _apiKey);
    await prefs.setString(_prefModel, _model);
    await prefs.setString(_prefCustomEndpoint, _customEndpoint);
  }
}
