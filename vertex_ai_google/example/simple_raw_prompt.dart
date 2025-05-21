import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:tekartik_prj_tktools/dsenv.dart';

Future<String> getGeminiApiKey() async {
  try {
    return await dsUserEnvGetVar('TEKARTIK_GEMINI_API_KEY');
  } catch (e) {
    stderr.writeln('Cannot find TEKARTIK_GEMINI_API_KEY');
    exit(1);
  }
}

Future<void> main(List<String> args) async {
  var apiKey = await getGeminiApiKey();
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );
  final prompt = 'Sum 1 and 4';
  final content = Content.text(prompt);
  final response = await model.generateContent([content]);
  stdout.writeln(response.text);
}
