# tekartik_firebase_vertex_ai_google

Google AI (Gemini api key) backend of the
[tekartik_firebase_vertex_ai](../vertex_ai/README.md) interface, in pure Dart
(Dart VM, servers, tools), on the `google_generative_ai` package.

## Getting started

Git packages, not on pub.dev:

```yaml
dependencies:
  tekartik_firebase_vertex_ai_google:
    git:
      url: https://github.com/tekartik/firebase_vertex_ai.dart
      path: vertex_ai_google
```

```dart
import 'dart:io';

// Re-exports package:tekartik_firebase_vertex_ai/vertex_ai.dart.
import 'package:tekartik_firebase_vertex_ai_google/vertex_ai_google.dart';

Future<void> main() async {
  // Never hard code nor print the api key.
  var vertexAi = FirebaseVertexAiGoogle(
    apiKey: Platform.environment['GEMINI_API_KEY']!,
  );
  var model = vertexAi.generativeModel(); // gemini-2.5-flash by default
  var response = await model.generateContent([Content.text('Sum 1 and 4')]);
  print(response.text);
}
```

`FirebaseVertexAiGoogle(apiKey: ...)` creates its own local app; with an
existing `tekartik_firebase_local` app use
`FirebaseVertexAiServiceGoogle(apiKey: ...).vertexAi(app)` (see the
[vertex_ai README](../vertex_ai/README.md) for the whole API: content, JSON
output with a `Schema`, generation config).

## Pitfalls

* The app given to `vertexAi(app)` must be a local app (`FirebaseAppLocal`).
* `google_generative_ai` is discontinued upstream: for new pure Dart code
  prefer `tekartik_google_ai` (same repo, `google_ai`), which also lists the
  models and generates images.
* Text and inline data parts only, no streaming, no function calling.

## Examples

`example/` (they read the key `TEKARTIK_GEMINI_API_KEY` from the local
`ds` env of `tekartik_prj_tktools`): `simple_prompt.dart` (JSON output),
`simple_raw_prompt.dart` (`google_generative_ai` directly),
`simple_list_models.dart` (rest api).

## Agent skills

`skills/tekartik-firebase-vertex-ai-google-setup`.
