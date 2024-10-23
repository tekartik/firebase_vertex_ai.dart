import 'dart:io';

import 'package:tekartik_firebase_vertex_ai/vertex_ai.dart';
import 'package:tekartik_firebase_vertex_ai_google/src/vertex_ai_google.dart';

import 'simple_raw_prompt.dart';

Future<void> main(List<String> args) async {
  var apiKey = await getGeminiApiKey();
  var vertexAi = FirebaseVertexAiGoogle(apiKey: apiKey);
  final model = vertexAi.generativeModel(
      generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema:
              Schema.object(properties: {'total': Schema.number()})));

  final prompt = 'Sum 1 and 4';
  final content = Content.text(prompt);
  final response = await model.generateContent([content]);
  stdout.writeln(response.text);
}
