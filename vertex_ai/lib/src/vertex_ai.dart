import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_vertex_ai/vertex_ai.dart';

/// Vertex AI service
abstract class FirebaseVertexAiService implements FirebaseAppProductService {
  /// Vertex AI app service
  FirebaseVertexAi vertexAi(FirebaseApp app);
}

/// Vertex AI app service
abstract class FirebaseVertexAi
    implements FirebaseAppProduct<FirebaseVertexAi> {
  /// Create a [GenerativeModel] backed by the generative model named [model].
  ///
  /// The [model] argument can be a model name (such as `'gemini-pro'`) or a
  /// model code (such as `'models/gemini-pro'`).
  /// There is no creation time check for whether the `model` string identifies
  /// a known and supported model. If not, attempts to generate content
  /// will fail.
  ///
  /// The optional [safetySettings] and [generationConfig] can be used to
  /// control and guide the generation. See [SafetySetting] and
  /// [GenerationConfig] for details.
  VaiGenerativeModel generativeModel({required String model});
}
