import 'package:googleai_dart/googleai_dart.dart' as googleai;
import 'generation_config.dart';
import 'google_ai.dart';
import 'google_ai_api.dart';
import 'google_ai_content.dart';
import 'google_ai_convert.dart';

/// A multimodal generative model (like Gemini).
///
/// Allows generating content from a prompt. Get one from
/// [GoogleAi.generativeModel].
abstract class GaiGenerativeModel {
  /// The model name this instance generates with, such as `gemini-2.5-flash`.
  String get model;

  /// Config applied to every request made through this model, null if none.
  GenerationConfig? get generationConfig;

  /// Generates content responding to [prompt].
  ///
  /// Sends a "generateContent" API request for the configured model,
  /// and waits for the response.
  ///
  /// Example:
  /// ```dart
  /// final response = await model.generateContent([Content.text(prompt)]);
  /// stdout.writeln(response.text);
  /// ```
  Future<GaiGenerateContentResponse> generateContent(
    Iterable<GaiContent> prompt,
  );
}

/// [GaiGenerativeModel] implementation on top of googleai_dart.
class GaiGenerativeModelImpl implements GaiGenerativeModel {
  /// Native googleai_dart client, owned by the [GoogleAi] instance.
  final googleai.GoogleAIClient nativeClient;

  @override
  final GenerationConfig? generationConfig;

  @override
  final String model;

  /// Constructor, [nativeClient] is the client used for every request,
  /// [model] the model name and [generationConfig] the optional config
  /// applied to every request.
  GaiGenerativeModelImpl({
    required this.nativeClient,
    required this.model,
    this.generationConfig,
  });

  @override
  Future<GaiGenerateContentResponse> generateContent(
    Iterable<GaiContent> prompt,
  ) async {
    var nativeResponse = await nativeClient.models.generateContent(
      model: model,
      request: googleai.GenerateContentRequest(
        contents: [for (var content in prompt) content.toNativeContent()],
        generationConfig: generationConfig?.toNativeGenerationConfig(),
      ),
    );
    return GaiGenerateContentResponseImpl(nativeResponse);
  }

  @override
  String toString() => 'GaiGenerativeModel($model)';
}
