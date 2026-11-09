/// Response from the model; supports multiple candidates.
abstract class VaiGenerateContentResponse {
  /// The text of the first candidate: the concatenation of its text parts.
  ///
  /// `null` if there is no candidate, or if the first candidate has no text
  /// part. When the prompt or the answer was blocked (safety, recitation),
  /// accessing it can throw the exception of the backend.
  String? get text;
}
