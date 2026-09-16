import 'dart:io';

import 'package:tekartik_google_ai/google_ai.dart';

import 'api_key.dart';

Future<void> main(List<String> args) async {
  var googleAi = GoogleAi(apiKey: getGeminiApiKey());
  try {
    var models = await googleAi.listModels();
    for (var model in models.where((model) => model.supportsGenerateContent)) {
      stdout.writeln('${model.id} (${model.displayName})');
    }
    stdout.writeln('${models.length} model(s)');
  } finally {
    googleAi.close();
  }
}
