/// Response from the model; supports multiple candidates.
abstract class VaiGenerateContentResponse {
  /// The text content of the first part of the first of [candidates], if any.
  ///
  /// If the prompt was blocked, or the first candidate was finished for a reason
  /// of [FinishReason.recitation] or [FinishReason.safety], accessing this text
  /// will throw a [google_ai.GenerativeAIException].
  ///
  /// If the first candidate's content contains any text parts, this value is
  /// the concatenation of the text.
  ///
  /// If there are no candidates, or if the first candidate does not contain any
  /// text parts, this value is `null`.
  String? get text;
}
