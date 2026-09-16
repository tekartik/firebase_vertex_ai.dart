import 'package:googleai_dart/googleai_dart.dart' as googleai;
import 'generation_config.dart';
import 'google_ai_content.dart';

/// Content conversion to the native googleai_dart api.
extension GaiContentNativeExtension on GaiContent {
  /// Convert to a native googleai_dart content.
  googleai.Content toNativeContent() => googleai.Content(
    role: role,
    parts: [for (var part in parts) part.toNativePart()],
  );
}

/// Content part conversion to the native googleai_dart api.
extension GaiContentPartNativeExtension on GaiContentPart {
  /// Convert to a native googleai_dart part.
  googleai.Part toNativePart() => switch (this) {
    GaiContentTextPart(:var text) => googleai.TextPart(text),
    GaiContentDataPart(:var mimeType, :var bytes) => googleai.InlineDataPart(
      googleai.Blob.fromBytes(mimeType, bytes),
    ),
  };
}

/// Generation config conversion to the native googleai_dart api.
extension GenerationConfigNativeExtension on GenerationConfig {
  /// Convert to a native googleai_dart generation config.
  googleai.GenerationConfig toNativeGenerationConfig() =>
      googleai.GenerationConfig(
        candidateCount: candidateCount,
        stopSequences: stopSequences.isEmpty ? null : stopSequences,
        maxOutputTokens: maxOutputTokens,
        temperature: temperature,
        topP: topP,
        topK: topK,
        responseMimeType: responseMimeType,
        responseSchema: responseSchema?.toJson(),
        responseModalities: [
          for (var modality
              in responseModalities ?? const <GaiResponseModality>[])
            modality.toNativeResponseModality(),
        ].nonEmptyOrNull(),
        imageConfig: imageConfig?.toNativeImageConfig(),
      );
}

/// Response modality conversion to the native googleai_dart api.
extension GaiResponseModalityNativeExtension on GaiResponseModality {
  /// Convert to a native googleai_dart response modality.
  googleai.ResponseModality toNativeResponseModality() => switch (this) {
    GaiResponseModality.text => googleai.ResponseModality.text,
    GaiResponseModality.image => googleai.ResponseModality.image,
    GaiResponseModality.audio => googleai.ResponseModality.audio,
  };
}

/// Image config conversion to the native googleai_dart api.
extension GaiImageConfigNativeExtension on GaiImageConfig {
  /// Convert to a native googleai_dart image config.
  googleai.ImageConfig toNativeImageConfig() =>
      googleai.ImageConfig(aspectRatio: aspectRatio, imageSize: imageSize);
}

extension _GaiListExtension<T> on List<T> {
  /// Null rather than an empty list, so that the field is left out of the
  /// request json.
  List<T>? nonEmptyOrNull() => isEmpty ? null : this;
}
