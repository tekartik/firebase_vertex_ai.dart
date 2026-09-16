import 'dart:io';

import 'package:tekartik_google_ai/google_ai.dart';

import 'api_key.dart';

Future<void> main(List<String> args) async {
  var googleAi = GoogleAi(apiKey: getGeminiApiKey());
  try {
    var model = googleAi.generativeModel(
      model: 'gemini-flash-lite-latest',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(properties: {'total': Schema.number()}),
      ),
    );

    final prompt = 'Sum 1 and 4';
    final content = Content.text(prompt);
    final response = await model.generateContent([content]);
    stdout.writeln(response.text);
  } finally {
    googleAi.close();
  }
}
