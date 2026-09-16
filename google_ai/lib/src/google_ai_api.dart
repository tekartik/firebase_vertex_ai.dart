import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';

// Only the Gai* names, the others would clash with googleai_dart.
import 'google_ai_content.dart'
    show GaiContentDataPart, GaiContentPart, GaiContentTextPart;

/// Response from the model; supports multiple candidates.
abstract class GaiGenerateContentResponse {
  /// The concatenation of every text part of every candidate, if any.
  ///
  /// With the default single candidate this is simply the generated text.
  ///
  /// If there are no candidates, or if no candidate contains any text part,
  /// this value is `null`.
  String? get text;

  /// Parts of the first candidate, empty if there is no candidate.
  ///
  /// Parts this abstraction does not model (thoughts, function calls, code
  /// execution) are dropped. Pass this back as `GaiContent.model(parts)` in a
  /// follow up prompt to refine a generated image.
  List<GaiContentPart> get parts;

  /// Image parts of the first candidate, empty if the response has none.
  ///
  /// Only populated when the request asked for the image modality, which
  /// `GoogleAi.generativeImageModel` does.
  List<GaiContentDataPart> get images;

  /// First entry of [images], null if the response has no image.
  GaiContentDataPart? get image;
}

/// [GaiGenerateContentResponse] implementation wrapping the native response.
class GaiGenerateContentResponseImpl implements GaiGenerateContentResponse {
  /// Native googleai_dart response.
  final GenerateContentResponse nativeResponse;

  /// Constructor, [nativeResponse] is the wrapped googleai_dart response.
  GaiGenerateContentResponseImpl(this.nativeResponse);

  @override
  String? get text => nativeResponse.text;

  @override
  late final List<GaiContentPart> parts = [
    for (var nativePart
        in nativeResponse.firstCandidate?.parts ?? const <Part>[])
      ?nativePart.toGaiContentPart(),
  ];

  @override
  late final List<GaiContentDataPart> images = [
    for (var part in parts)
      if (part is GaiContentDataPart && part.isImage) part,
  ];

  @override
  GaiContentDataPart? get image => images.isEmpty ? null : images.first;

  @override
  String toString() =>
      'GaiGenerateContentResponse($text, ${images.length} image(s))';
}

/// Native googleai_dart part conversion.
extension GaiContentPartNativeResponseExtension on Part {
  /// Convert a native googleai_dart part to a [GaiContentPart].
  ///
  /// Returns null for the part kinds this abstraction does not model, so that
  /// they can be skipped rather than failing the whole response.
  GaiContentPart? toGaiContentPart() => switch (this) {
    TextPart(:var text) => GaiContentTextPart(text),
    InlineDataPart(:var inlineData) => GaiContentDataPart(
      inlineData.mimeType,
      base64Decode(inlineData.data),
    ),
    _ => null,
  };
}

/// Description of a model, as returned by `GoogleAi.listModels`.
class GaiModelInfo {
  /// Resource name, such as `models/gemini-2.5-flash`.
  final String name;

  /// Human readable name, such as `Gemini 2.5 Flash`, null if not set.
  final String? displayName;

  /// Human readable description of the model, null if not set.
  final String? description;

  /// Maximum number of input tokens accepted, null if not reported.
  final int? inputTokenLimit;

  /// Maximum number of output tokens produced, null if not reported.
  final int? outputTokenLimit;

  /// Methods the model supports, such as `generateContent`, empty if none
  /// is reported.
  final List<String> supportedGenerationMethods;

  /// Constructor.
  GaiModelInfo({
    required this.name,
    this.displayName,
    this.description,
    this.inputTokenLimit,
    this.outputTokenLimit,
    this.supportedGenerationMethods = const [],
  });

  /// Model id without the `models/` prefix, such as `gemini-2.5-flash`.
  ///
  /// This is what `GoogleAi.generativeModel` expects as its `model` argument.
  String get id => name.split('/').last;

  /// True if the model supports `generateContent`.
  bool get supportsGenerateContent =>
      supportedGenerationMethods.contains('generateContent');

  @override
  String toString() => 'GaiModelInfo($id)';
}

/// Native googleai_dart model conversion.
extension GaiModelInfoNativeExtension on Model {
  /// Convert a native googleai_dart model to a [GaiModelInfo].
  GaiModelInfo toGaiModelInfo() => GaiModelInfo(
    name: name,
    displayName: displayName,
    description: description,
    inputTokenLimit: inputTokenLimit,
    outputTokenLimit: outputTokenLimit,
    supportedGenerationMethods: supportedGenerationMethods ?? const [],
  );
}
