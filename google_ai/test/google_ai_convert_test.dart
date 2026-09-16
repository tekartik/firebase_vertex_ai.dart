import 'dart:convert';
import 'dart:typed_data';

import 'package:googleai_dart/googleai_dart.dart' as googleai;
import 'package:tekartik_google_ai/google_ai.dart';
import 'package:tekartik_google_ai/src/google_ai_api.dart';
import 'package:tekartik_google_ai/src/google_ai_convert.dart';
import 'package:test/test.dart';

void main() {
  group('content', () {
    test('text', () {
      var native = Content.text('Sum 1 and 4').toNativeContent();
      expect(native.role, gaiContentRoleUser);
      expect(native.toJson(), {
        'role': 'user',
        'parts': [
          {'text': 'Sum 1 and 4'},
        ],
      });
    });
    test('model role', () {
      var native = GaiContent.model([TextPart('hi')]).toNativeContent();
      expect(native.role, gaiContentRoleModel);
    });
    test('data', () {
      var bytes = Uint8List.fromList([1, 2, 3]);
      var native = Content.data('image/png', bytes).toNativeContent();
      var part = native.parts.first as googleai.InlineDataPart;
      expect(part.inlineData.mimeType, 'image/png');
      expect(part.inlineData.data, base64Encode(bytes));
    });
    test('multi', () {
      var native = GaiContent.multi([
        TextPart('one'),
        TextPart('two'),
      ]).toNativeContent();
      expect(native.parts.length, 2);
    });
  });
  group('generationConfig', () {
    test('empty', () {
      var native = GenerationConfig().toNativeGenerationConfig();
      expect(native.toJson(), isEmpty);
      // An empty stop sequence list must not be sent as an empty array.
      expect(native.stopSequences, isNull);
    });
    test('values', () {
      var native = GenerationConfig(
        candidateCount: 1,
        stopSequences: ['stop'],
        maxOutputTokens: 100,
        temperature: 0.5,
        topP: 0.9,
        topK: 10,
        responseMimeType: 'application/json',
      ).toNativeGenerationConfig();
      expect(native.toJson(), {
        'candidateCount': 1,
        'stopSequences': ['stop'],
        'maxOutputTokens': 100,
        'temperature': 0.5,
        'topP': 0.9,
        'topK': 10,
        'responseMimeType': 'application/json',
      });
    });
    test('responseSchema', () {
      var native = GenerationConfig(
        responseSchema: Schema.object(
          properties: {'total': Schema.number(), 'comment': Schema.string()},
          optionalProperties: ['comment'],
        ),
      ).toNativeGenerationConfig();
      expect(native.responseSchema, {
        'type': 'OBJECT',
        'properties': {
          'total': {'type': 'NUMBER'},
          'comment': {'type': 'STRING'},
        },
        'required': ['total'],
      });
    });
  });
  group('modelInfo', () {
    test('conversion', () {
      var info = const googleai.Model(
        name: 'models/gemini-2.5-flash',
        displayName: 'Gemini 2.5 Flash',
        description: 'Fast',
        inputTokenLimit: 1048576,
        outputTokenLimit: 65536,
        supportedGenerationMethods: ['generateContent', 'countTokens'],
      ).toGaiModelInfo();
      expect(info.name, 'models/gemini-2.5-flash');
      expect(info.id, 'gemini-2.5-flash');
      expect(info.displayName, 'Gemini 2.5 Flash');
      expect(info.description, 'Fast');
      expect(info.inputTokenLimit, 1048576);
      expect(info.outputTokenLimit, 65536);
      expect(info.supportsGenerateContent, isTrue);
    });
    test('no generation method', () {
      var info = const googleai.Model(
        name: 'models/embedding-001',
      ).toGaiModelInfo();
      expect(info.supportedGenerationMethods, isEmpty);
      expect(info.supportsGenerateContent, isFalse);
    });
  });
}
