import 'package:tekartik_firebase_vertex_ai/vertex_ai.dart';

/// A multimodel generative model (like Gemini).
///
/// Allows generating content, creating embeddings, and counting the number of
/// tokens in a piece of content.
abstract class VaiGenerativeModel {
  /// Generates content responding to [prompt].
  ///
  /// Sends a "generateContent" API request for the configured model,
  /// and waits for the response.
  ///
  /// Example:
  /// ```dart
  /// final response = await model.generateContent([Content.text(prompt)]);
  /// print(response.text);
  /// ```
  Future<VaiGenerateContentResponse> generateContent(
    Iterable<VaiContent> prompt,
  );
}
