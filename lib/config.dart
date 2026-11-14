class AppConfig {
  static const String openRouterApiKey = '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';
  static const String apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String model = 'google/gemini-2.5-flash';

  /// موديلات النص
  static const List<String> models = [
    'google/gemini-2.5-flash',
    'openai/gpt-4o-mini',
  ];

  /// موديلات بتفهم الصور فقط
  static const List<String> visionModels = [
    'google/gemini-2.5-flash',
    'openai/gpt-4o-mini',
  ];

  static const String visionModel = 'google/gemini-2.5-flash';
}