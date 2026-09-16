import 'dart:io';

import 'api_key.dart';

/// Dump the Google AI api key the other examples run with.
///
/// Useful to check what `TEKARTIK_GEMINI_API_KEY` resolves to, and to confirm
/// it is set at all, since [getGeminiApiKey] otherwise fails at the first
/// request.
///
/// The key is printed in clear: do not run this while sharing a screen, and
/// do not paste its output anywhere.
void main(List<String> args) {
  stdout.writeln(getGeminiApiKey());
}
