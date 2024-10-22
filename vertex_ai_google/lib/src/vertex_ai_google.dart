import 'package:google_generative_ai/google_generative_ai.dart' as gai;
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
  VaiGenerativeModel generativeModel({String? model}) {
    model ??= vertexAiModelGemini1dot5Flash;
    var nativeModel =
        gai.GenerativeModel(model: model, apiKey: serviceGoogle.apiKey);
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
