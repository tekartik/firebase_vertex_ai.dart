import 'package:tekartik_firebase_vertex_ai_google/src/vertex_ai_google.dart';
import 'package:tekartik_firebase_vertex_ai_google/vertex_ai_google.dart';
import 'package:test/test.dart';

void main() {
  group('convert', () {
    test('generationConfig', () {
      var config = GenerationConfig(
        candidateCount: 1,
        stopSequences: ['END'],
        maxOutputTokens: 10,
        temperature: 0.5,
        topP: 0.9,
        topK: 3,
        responseMimeType: 'application/json',
      ).toGaiGenerationConfig();
      expect(config.toJson(), {
        'candidateCount': 1,
        'stopSequences': ['END'],
        'maxOutputTokens': 10,
        'temperature': 0.5,
        'topP': 0.9,
        'topK': 3,
        'responseMimeType': 'application/json',
      });
    });
    test('default model', () {
      expect(vertexAiModelDefault, 'gemini-2.5-flash');
    });
  });
}
