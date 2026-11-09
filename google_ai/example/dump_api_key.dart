import 'dart:io';

import 'api_key.dart';

/// Show which Google AI api key the other examples run with, masked.
///
/// Useful to check that `TEKARTIK_GEMINI_API_KEY` is set (otherwise
/// [getGeminiApiKey] exits with an error) and which key it is: only its first
/// characters and its length are printed, never the key itself.
void main(List<String> args) {
  var apiKey = getGeminiApiKey();
  var start = apiKey.length > 12 ? apiKey.substring(0, 4) : '';
  stdout.writeln('$start... (${apiKey.length} characters)');
}
