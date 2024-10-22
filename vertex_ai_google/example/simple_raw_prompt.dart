import 'dart:io';

import 'package:dev_build/shell.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<String> getGeminiApiKey() async {
  var apiKey = ShellEnvironment().vars['TEKARTIK_GEMINI_API_KEY'];
  if (apiKey == null) {
    stderr.writeln('TEKARTIK_GEMINI_API_KEY not set');
    exit(1);
  }
  return apiKey;
}

Future<void> main(List<String> args) async {
  var apiKey = await getGeminiApiKey();
  final model =
      GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
  final prompt = 'Sum 1 and 4';
  final content = Content.text(prompt);
  final response = await model.generateContent([content]);
  stdout.writeln(response.text);
}
