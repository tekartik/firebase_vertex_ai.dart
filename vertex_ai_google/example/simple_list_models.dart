import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'simple_raw_prompt.dart';

/// Models endpoint of the generative language rest api.
///
/// Neither `google_generative_ai` nor the vertex ai abstraction expose a
/// `listModels` call, so the rest api is used directly here.
final _modelsUri = Uri.parse(
  'https://generativelanguage.googleapis.com/v1beta/models',
);

Future<void> main(List<String> args) async {
  var apiKey = getGeminiApiKey();
  var count = 0;
  String? pageToken;
  do {
    var uri = _modelsUri.replace(
      queryParameters: {'pageSize': '100', 'pageToken': ?pageToken},
    );
    var response = await http.get(uri, headers: {'x-goog-api-key': apiKey});
    if (response.statusCode != 200) {
      stderr.writeln('Error ${response.statusCode} listing models');
      stderr.writeln(response.body);
      exit(1);
    }
    var map = jsonDecode(response.body) as Map<String, Object?>;
    var models = (map['models'] as List?)?.cast<Map<String, Object?>>() ?? [];
    for (var model in models) {
      /// `models/gemini-1.5-flash`, strip the `models/` prefix.
      var name = (model['name'] as String?)?.split('/').last;
      var methods = (model['supportedGenerationMethods'] as List?)?.join(', ');
      stdout.writeln('$name (${model['displayName']}) [$methods]');
      count++;
    }
    pageToken = map['nextPageToken'] as String?;
  } while (pageToken != null);
  stdout.writeln('$count model(s)');
}
