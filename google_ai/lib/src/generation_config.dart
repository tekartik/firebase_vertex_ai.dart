import 'schema.dart';

/// Output modality a model may produce.
///
/// Image models such as [googleAiModelDefaultImage] must be asked for
/// [GaiResponseModality.image], and they always return
/// [GaiResponseModality.text] alongside it.
enum GaiResponseModality {
  /// Text output.
  text,

  /// Image output, returned as inline data parts.
  image,

  /// Audio output, returned as inline data parts.
  audio,
}

/// Options for image generation.
final class GaiImageConfig {
  /// The aspect ratio of the image to generate.
  ///
  /// Supported values: `1:1`, `2:3`, `3:2`, `3:4`, `4:3`, `9:16`, `16:9`,
  /// `21:9`. If null the model picks one.
  final String? aspectRatio;

  /// The size of the generated image.
  ///
  /// Supported values: `1K`, `2K`, `4K`. If null the model uses `1K`.
  final String? imageSize;

  /// Constructor, [aspectRatio] and [imageSize] are both optional.
  const GaiImageConfig({this.aspectRatio, this.imageSize});

  @override
  String toString() => 'GaiImageConfig($aspectRatio, $imageSize)';
}

/// Configuration options for model generation and outputs.
final class GenerationConfig {
  /// Number of generated responses to return.
  ///
  /// This value must be between `[1, 8]`, inclusive. If unset, this will default
  /// to 1.
  final int? candidateCount;

  /// The set of character sequences (up to 5) that will stop output generation.
  ///
  /// If specified, the API will stop at the first appearance of a stop
  /// sequence. The stop sequence will not be included as part of the response.
  final List<String> stopSequences;

  /// The maximum number of tokens to include in a candidate.
  ///
  /// If unset, this will default to output_token_limit specified in the `Model`
  /// specification.
  final int? maxOutputTokens;

  /// Controls the randomness of the output.
  ///
  /// Note: The default value varies by model.
  ///
  /// Values can range from `[0.0, infinity]`, inclusive. A value temperature
  /// must be greater than 0.0.
  final double? temperature;

  /// The maximum cumulative probability of tokens to consider when sampling.
  ///
  /// The model uses combined Top-k and nucleus sampling. Tokens are sorted
  /// based on their assigned probabilities so that only the most likely tokens
  /// are considered. Top-k sampling directly limits the maximum number of
  /// tokens to consider, while Nucleus sampling limits number of tokens based
  /// on the cumulative probability.
  ///
  /// Note: The default value varies by model.
  final double? topP;

  /// The maximum number of tokens to consider when sampling.
  ///
  /// The model uses combined Top-k and nucleus sampling. Top-k sampling
  /// considers the set of `top_k` most probable tokens. Defaults to 40.
  ///
  /// Note: The default value varies by model.
  final int? topK;

  /// Output response mimetype of the generated candidate text.
  ///
  /// Supported mimetype:
  /// - `text/plain`: (default) Text output.
  /// - `application/json`: JSON response in the candidates.
  final String? responseMimeType;

  /// Output response schema of the generated candidate text.
  ///
  /// - Note: This only applies when the specified ``responseMIMEType`` supports
  ///   a schema; currently this is limited to `application/json`.
  final Schema? responseSchema;

  /// Modalities the model is allowed to produce, null for the model default
  /// (text only).
  ///
  /// To generate images this must contain [GaiResponseModality.image], and
  /// the model must be an image model. [GoogleAi.generativeImageModel] sets
  /// this up for you.
  final List<GaiResponseModality>? responseModalities;

  /// Options applied to generated images, null for the model defaults.
  ///
  /// Only meaningful when [responseModalities] contains
  /// [GaiResponseModality.image].
  final GaiImageConfig? imageConfig;

  /// Constructor
  GenerationConfig({
    this.candidateCount,
    this.stopSequences = const [],
    this.maxOutputTokens,
    this.temperature,
    this.topP,
    this.topK,
    this.responseMimeType,
    this.responseSchema,
    this.responseModalities,
    this.imageConfig,
  });
}
