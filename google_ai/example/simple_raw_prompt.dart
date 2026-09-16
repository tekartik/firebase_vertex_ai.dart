import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

import 'api_key.dart';

/// Same as `simple_prompt.dart` but using googleai_dart directly, without
/// the tekartik_google_ai abstraction.
Future<void> main(List<String> args) async {
  var client = GoogleAIClient(
    config: GoogleAIConfig.googleAI(
      authProvider: ApiKeyProvider(
        getGeminiApiKey(),
        placement: AuthPlacement.header,
      ),
    ),
  );
  try {
    final response = await client.models.generateContent(
      model: 'gemini-flash-lite-latest',
      request: GenerateContentRequest(contents: [Content.text('Sum 1 and 4')]),
    );
    stdout.writeln(response.text);
  } finally {
    client.close();
  }
}
