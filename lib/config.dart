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