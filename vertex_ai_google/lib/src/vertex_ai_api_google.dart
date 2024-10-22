import 'package:google_generative_ai/google_generative_ai.dart' as gai;
import 'package:tekartik_firebase_vertex_ai/vertex_ai.dart';

/// Response Google
class VaiGenerateContentResponseGoogle implements VaiGenerateContentResponse {
  /// Native response
  final gai.GenerateContentResponse nativeResponse;

  /// Constructor
  VaiGenerateContentResponseGoogle(this.nativeResponse);

  @override
  String? get text => nativeResponse.text;
}
