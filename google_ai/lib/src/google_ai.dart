import 'package:googleai_dart/googleai_dart.dart' as googleai;
import 'generation_config.dart';
import 'google_ai_api.dart';
import 'google_ai_constant.dart';
import 'google_ai_model.dart';

/// Options needed to talk to the Google AI (Gemini) api.
class GoogleAiOptions {
  /// Google AI api key, as created on https://aistudio.google.com/apikey.
  final String apiKey;

  /// Constructor, [apiKey] is the Google AI api key.
  const GoogleAiOptions({required this.apiKey});
}

/// Google AI service, creates [GoogleAi] instances.
///
/// The service itself holds no state, it is the equivalent of a firebase
/// product service without the firebase app indirection.
abstract class GoogleAiService {
  /// Default implementation, backed by googleai_dart.
  factory GoogleAiService() => _GoogleAiService();

  /// Create a [GoogleAi] instance for [options].
  ///
  /// Each call creates a new instance owning its own http client, call
  /// [GoogleAi.close] when done with it.
  GoogleAi googleAi(GoogleAiOptions options);
}

/// Default [GoogleAiService] instance.
final googleAiService = GoogleAiService();

class _GoogleAiService implements GoogleAiService {
  @override
  GoogleAi googleAi(GoogleAiOptions options) => _GoogleAi(options);
}

/// Google AI entry point, creates models and lists the available ones.
abstract class GoogleAi {
  /// Create an instance directly from an [apiKey], the common case.
  ///
  /// Shortcut for `googleAiService.googleAi(GoogleAiOptions(apiKey: apiKey))`.
  /// Call [close] when done with it.
  factory GoogleAi({required String apiKey}) =>
      googleAiService.googleAi(GoogleAiOptions(apiKey: apiKey));

  /// Options this instance was created with.
  GoogleAiOptions get options;

  /// Create a [GaiGenerativeModel] backed by the generative model named
  /// [model].
  ///
  /// The [model] argument can be a model name (such as `'gemini-2.5-flash'`)
  /// or a model code (such as `'models/gemini-2.5-flash'`), and defaults to
  /// [googleAiModelDefault]. There is no creation time check for whether the
  /// `model` string identifies a known and supported model. If not, attempts
  /// to generate content will fail.
  ///
  /// The optional [generationConfig] is applied to every request made through
  /// the returned model, and can be used to control and guide the generation.
  GaiGenerativeModel generativeModel({
    String? model,
    GenerationConfig? generationConfig,
  });

  /// Create a [GaiGenerativeModel] that generates images.
  ///
  /// [model] defaults to [googleAiModelDefaultImage] and must be an image
  /// model, [imageConfig] controls the aspect ratio and size of the generated
  /// images, [generationConfig] is an optional base config whose
  /// `responseModalities` and `imageConfig` are overridden.
  ///
  /// The returned model asks for both the text and image modalities, which is
  /// what image models expect. Read the images from
  /// [GaiGenerateContentResponse.images]; note that
  /// [GaiGenerateContentResponse.text] is often null for these models, they
  /// may answer with the image alone.
  GaiGenerativeModel generativeImageModel({
    String? model,
    GaiImageConfig? imageConfig,
    GenerationConfig? generationConfig,
  });

  /// List every model available to the api key, following pagination.
  ///
  /// Use [GaiModelInfo.supportsGenerateContent] to keep only the models usable
  /// with [generativeModel].
  Future<List<GaiModelInfo>> listModels();

  /// Release the underlying http client.
  ///
  /// The instance must not be used afterwards.
  void close();
}

class _GoogleAi implements GoogleAi {
  @override
  final GoogleAiOptions options;

  late final googleai.GoogleAIClient nativeClient = googleai.GoogleAIClient(
    config: googleai.GoogleAIConfig.googleAI(
      // Header rather than query param, so that the key does not end up in
      // urls and server logs.
      authProvider: googleai.ApiKeyProvider(
        options.apiKey,
        placement: googleai.AuthPlacement.header,
      ),
    ),
  );

  _GoogleAi(this.options);

  @override
  GaiGenerativeModel generativeModel({
    String? model,
    GenerationConfig? generationConfig,
  }) {
    return GaiGenerativeModelImpl(
      nativeClient: nativeClient,
      model: model ?? googleAiModelDefault,
      generationConfig: generationConfig,
    );
  }

  @override
  GaiGenerativeModel generativeImageModel({
    String? model,
    GaiImageConfig? imageConfig,
    GenerationConfig? generationConfig,
  }) {
    var config = generationConfig;
    return generativeModel(
      model: model ?? googleAiModelDefaultImage,
      generationConfig: GenerationConfig(
        candidateCount: config?.candidateCount,
        stopSequences: config?.stopSequences ?? const [],
        maxOutputTokens: config?.maxOutputTokens,
        temperature: config?.temperature,
        topP: config?.topP,
        topK: config?.topK,
        responseMimeType: config?.responseMimeType,
        responseSchema: config?.responseSchema,
        // Both modalities, which is what image models expect. The answer
        // may still come back with no text part at all.
        responseModalities: const [
          GaiResponseModality.text,
          GaiResponseModality.image,
        ],
        imageConfig: imageConfig ?? config?.imageConfig,
      ),
    );
  }

  @override
  Future<List<GaiModelInfo>> listModels() async {
    var list = <GaiModelInfo>[];
    String? pageToken;
    do {
      var response = await nativeClient.models.list(
        pageSize: 100,
        pageToken: pageToken,
      );
      list.addAll(response.models.map((model) => model.toGaiModelInfo()));
      var nextPageToken = response.nextPageToken;
      // An empty token means the last page, guard against looping forever.
      pageToken = (nextPageToken?.isEmpty ?? true) ? null : nextPageToken;
    } while (pageToken != null);
    return list;
  }

  @override
  void close() => nativeClient.close();

  @override
  String toString() => 'GoogleAi()';
}
