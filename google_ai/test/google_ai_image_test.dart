import 'dart:convert';
import 'dart:typed_data';

import 'package:googleai_dart/googleai_dart.dart' as googleai;
import 'package:tekartik_google_ai/google_ai.dart';
import 'package:tekartik_google_ai/src/google_ai_api.dart';
import 'package:tekartik_google_ai/src/google_ai_convert.dart';
import 'package:test/test.dart';

/// A 1x1 png, small enough to inline.
final pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmM'
  'IQAAAABJRU5ErkJggg==',
);

/// Native response as the rest api returns it for an image generation.
googleai.GenerateContentResponse nativeImageResponse() =>
    googleai.GenerateContentResponse.fromJson({
      'candidates': [
        {
          'content': {
            'role': 'model',
            'parts': [
              {'text': 'Here is your image'},
              {
                'inlineData': {
                  'mimeType': 'image/png',
                  'data': base64Encode(pngBytes),
                },
              },
            ],
          },
        },
      ],
    });

void main() {
  group('request', () {
    test('responseModalities', () {
      var native = GenerationConfig(
        responseModalities: [
          GaiResponseModality.text,
          GaiResponseModality.image,
        ],
      ).toNativeGenerationConfig();
      expect(native.toJson(), {
        'responseModalities': ['TEXT', 'IMAGE'],
      });
    });
    test('no responseModalities', () {
      // Neither null nor an empty list may reach the request.
      expect(GenerationConfig().toNativeGenerationConfig().toJson(), isEmpty);
      expect(
        GenerationConfig(
          responseModalities: [],
        ).toNativeGenerationConfig().toJson(),
        isEmpty,
      );
    });
    test('imageConfig', () {
      var native = GenerationConfig(
        imageConfig: const GaiImageConfig(aspectRatio: '16:9', imageSize: '2K'),
      ).toNativeGenerationConfig();
      expect(native.toJson(), {
        'imageConfig': {'aspectRatio': '16:9', 'imageSize': '2K'},
      });
    });
    test('generativeImageModel config', () {
      var googleAi = GoogleAi(apiKey: 'dummy');
      try {
        var model = googleAi.generativeImageModel(
          imageConfig: const GaiImageConfig(aspectRatio: '1:1'),
        );
        expect(model.model, googleAiModelDefaultImage);
        expect(model.generationConfig!.toNativeGenerationConfig().toJson(), {
          'responseModalities': ['TEXT', 'IMAGE'],
          'imageConfig': {'aspectRatio': '1:1'},
        });
      } finally {
        googleAi.close();
      }
    });
    test('generativeImageModel keeps the base config', () {
      var googleAi = GoogleAi(apiKey: 'dummy');
      try {
        var model = googleAi.generativeImageModel(
          model: googleAiModelGemini3ProImage,
          generationConfig: GenerationConfig(temperature: 0.2),
        );
        expect(model.model, googleAiModelGemini3ProImage);
        expect(model.generationConfig!.toNativeGenerationConfig().toJson(), {
          'temperature': 0.2,
          'responseModalities': ['TEXT', 'IMAGE'],
        });
      } finally {
        googleAi.close();
      }
    });
  });
  group('response', () {
    test('image parts', () {
      var response = GaiGenerateContentResponseImpl(nativeImageResponse());
      expect(response.text, 'Here is your image');
      expect(response.parts.length, 2);
      expect(response.images.length, 1);
      var image = response.image!;
      expect(image.mimeType, 'image/png');
      expect(image.bytes, pngBytes);
      expect(image.isImage, isTrue);
    });
    test('image only response has no text', () {
      // What gemini-2.5-flash-image actually answers: the image alone.
      var response = GaiGenerateContentResponseImpl(
        googleai.GenerateContentResponse.fromJson({
          'candidates': [
            {
              'content': {
                'role': 'model',
                'parts': [
                  {
                    'inlineData': {
                      'mimeType': 'image/png',
                      'data': base64Encode(pngBytes),
                    },
                  },
                ],
              },
            },
          ],
        }),
      );
      expect(response.text, isNull);
      expect(response.images.length, 1);
      expect(response.image!.bytes, pngBytes);
    });
    test('text only response has no image', () {
      var response = GaiGenerateContentResponseImpl(
        googleai.GenerateContentResponse.fromJson({
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'no image here'},
                ],
              },
            },
          ],
        }),
      );
      expect(response.images, isEmpty);
      expect(response.image, isNull);
      expect(response.parts.length, 1);
    });
    test('empty response', () {
      var response = GaiGenerateContentResponseImpl(
        googleai.GenerateContentResponse.fromJson({}),
      );
      expect(response.text, isNull);
      expect(response.parts, isEmpty);
      expect(response.image, isNull);
    });
    test('unmodelled parts are dropped', () {
      var response = GaiGenerateContentResponseImpl(
        googleai.GenerateContentResponse.fromJson({
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'functionCall': {
                      'name': 'doIt',
                      'args': <String, Object?>{},
                    },
                  },
                  {'text': 'kept'},
                ],
              },
            },
          ],
        }),
      );
      expect(response.parts.length, 1);
      expect((response.parts.first as GaiContentTextPart).text, 'kept');
    });
    test('non image inline data is not an image', () {
      var response = GaiGenerateContentResponseImpl(
        googleai.GenerateContentResponse.fromJson({
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'inlineData': {
                      'mimeType': 'audio/wav',
                      'data': base64Encode([1, 2, 3]),
                    },
                  },
                ],
              },
            },
          ],
        }),
      );
      expect(response.parts.length, 1);
      expect(response.images, isEmpty);
    });
    test('round trip to a follow up prompt', () {
      // What the image edit example does: feed the generated parts back.
      var response = GaiGenerateContentResponseImpl(nativeImageResponse());
      var native = GaiContent.model(response.parts).toNativeContent();
      expect(native.role, gaiContentRoleModel);
      expect(native.parts.length, 2);
      var dataPart = native.parts[1] as googleai.InlineDataPart;
      expect(dataPart.inlineData.mimeType, 'image/png');
      expect(base64Decode(dataPart.inlineData.data), pngBytes);
    });
  });
  group('content', () {
    test('image data part', () {
      var part = InlineDataPart('image/png', Uint8List.fromList(pngBytes));
      expect(part.isImage, isTrue);
      expect(InlineDataPart('audio/wav', Uint8List(0)).isImage, isFalse);
    });
  });
}
