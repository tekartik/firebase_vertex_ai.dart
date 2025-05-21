import 'package:google_generative_ai/google_generative_ai.dart' as gai;
import 'package:tekartik_firebase_vertex_ai_google/vertex_ai_google.dart';

import 'vertex_ai_api_google.dart';

extension on Iterable<VaiContent> {
  Iterable<gai.Content> toNative() {
    return map((e) => e.toNative());
  }
}

extension on VaiContent {
  gai.Content toNative() {
    return gai.Content(role, parts.map((e) => e.toNative()).toList());
  }
}

extension on VaiContentPart {
  gai.Part toNative() {
    var part = this;
    if (part is VaiContentTextPart) {
      return gai.TextPart(part.text);
    } else if (part is VaiContentDataPart) {
      return gai.DataPart(part.mimeType, part.bytes);
    } else {
      throw 'Unsupported part $part (${part.runtimeType})';
    }
  }
}

/// Google impl
class VaiGenerativeModelGoogle implements VaiGenerativeModel {
  /// Vertex AI
  final FirebaseVertexAiGoogle vertexAiGoogle;

  /// The native instance
  final gai.GenerativeModel nativeInstance;

  /// Constructor
  VaiGenerativeModelGoogle(this.vertexAiGoogle, this.nativeInstance);

  @override
  Future<VaiGenerateContentResponse> generateContent(
    Iterable<VaiContent> prompt,
  ) async {
    var nativeResponse = await nativeInstance.generateContent(
      prompt.toNative(),
    );
    return VaiGenerateContentResponseGoogle(nativeResponse);
  }
}
