import 'package:google_generative_ai/google_generative_ai.dart' as gai;
import 'package:tekartik_common_utils/list_utils.dart';
import 'package:tekartik_firebase/firebase_mixin.dart';
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_vertex_ai/vertex_ai.dart';

import 'vertex_ai_model_google.dart';

/// Google service interface
abstract class FirebaseVertexAiServiceGoogle
    implements FirebaseVertexAiService {
  /// Optionnal auth service
  ///
  factory FirebaseVertexAiServiceGoogle({required String apiKey}) {
    return _FirebaseVertexAiServiceGoogle(apiKey: apiKey);
  }
}

class _FirebaseVertexAiServiceGoogle
    with FirebaseProductServiceMixin<FirebaseVertexAi>
    implements FirebaseVertexAiServiceGoogle {
  final String apiKey;

  _FirebaseVertexAiServiceGoogle({required this.apiKey});

  @override
  FirebaseVertexAiGoogle vertexAi(FirebaseApp app) {
    return getInstance(app, () {
      var appGoogle = app as FirebaseAppLocal;
      return _FirebaseVertexAiGoogle(this, appGoogle);
    });
  }
}

class _FirebaseVertexAiGoogle
    with FirebaseAppProductMixin<FirebaseVertexAi>
    implements FirebaseVertexAiGoogle {
  final _FirebaseVertexAiServiceGoogle serviceGoogle;
  final FirebaseAppLocal appLocal;

  _FirebaseVertexAiGoogle(this.serviceGoogle, this.appLocal);

  @override
  FirebaseApp get app => appLocal;

  @override
  VaiGenerativeModel generativeModel(
      {String? model, GenerationConfig? generationConfig}) {
    model ??= vertexAiModelGemini1dot5Flash;
    var nativeModel = gai.GenerativeModel(
        model: model,
        apiKey: serviceGoogle.apiKey,
        generationConfig: generationConfig?.toGaiGenerationConfig());
    return VaiGenerativeModelGoogle(this, nativeModel);
  }
}

/// Google service
abstract class FirebaseVertexAiGoogle implements FirebaseVertexAi {
  /// Allow no app direct creation
  factory FirebaseVertexAiGoogle({required String apiKey}) {
    var appLocal = newFirebaseAppLocal();
    var service = FirebaseVertexAiServiceGoogle(apiKey: apiKey);
    return service.vertexAi(appLocal) as FirebaseVertexAiGoogle;
  }
}

extension on SchemaType {
  gai.SchemaType toGaiSchemaType() {
    switch (this) {
      case SchemaType.object:
        return gai.SchemaType.object;
      case SchemaType.array:
        return gai.SchemaType.array;
      case SchemaType.integer:
        return gai.SchemaType.integer;
      case SchemaType.boolean:
        return gai.SchemaType.boolean;
      case SchemaType.string:
        return gai.SchemaType.string;
      case SchemaType.number:
        return gai.SchemaType.number;
    }
  }
}

extension on Map<String, Object?> {
  List<String>? keysWithout(List<String>? without) {
    var list = List.of(keys);
    if (without != null) {
      list.removeWhere((key) => without.contains(key));
    }
    return list.nonEmpty();
  }
}

extension on Schema {
  gai.Schema toGaiSchema() {
    return gai.Schema(type.toGaiSchemaType(),
        items: items?.toGaiSchema(),
        format: format,
        description: description,
        enumValues: enumValues,
        nullable: nullable,
        properties:
            properties?.map((key, value) => MapEntry(key, value.toGaiSchema())),
        requiredProperties: properties?.keysWithout(optionalProperties));
  }
}

extension on GenerationConfig {
  gai.GenerationConfig toGaiGenerationConfig() {
    return gai.GenerationConfig(
        candidateCount: candidateCount,
        maxOutputTokens: maxOutputTokens,
        temperature: temperature,
        topP: topP,
        topK: topK,
        responseMimeType: responseMimeType,
        responseSchema: responseSchema?.toGaiSchema());
  }
}
