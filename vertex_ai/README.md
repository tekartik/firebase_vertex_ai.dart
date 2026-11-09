# tekartik_firebase_vertex_ai

Platform neutral Vertex AI / Gemini interface, as a product of a
[tekartik_firebase](https://github.com/tekartik/firebase.dart/tree/master/firebase)
app: a `FirebaseVertexAiService` gives a `FirebaseVertexAi` per app, which
creates `VaiGenerativeModel`s that answer `generateContent` (text and inline
data, JSON output with a `Schema`).

This package has no backend of its own, see [Backends](#backends). For a
standalone Gemini client (api key only, no Firebase app, model listing, image
generation) use `tekartik_google_ai` (same repo, `google_ai`).

## Getting started

Git packages, not on pub.dev. The interface, and a backend, here the Google AI
one (Dart VM, api key):

```yaml
dependencies:
  tekartik_firebase_vertex_ai:
    git:
      url: https://github.com/tekartik/firebase_vertex_ai.dart
      path: vertex_ai
  tekartik_firebase_vertex_ai_google:
    git:
      url: https://github.com/tekartik/firebase_vertex_ai.dart
      path: vertex_ai_google
  tekartik_firebase_local:
    git:
      url: https://github.com/tekartik/firebase.dart
      path: firebase_local
```

```dart
import 'dart:io';

import 'package:tekartik_firebase_local/firebase_local.dart';
// Re-exports package:tekartik_firebase_vertex_ai/vertex_ai.dart.
import 'package:tekartik_firebase_vertex_ai_google/vertex_ai_google.dart';

Future<void> main() async {
  var app = newFirebaseAppMemory();
  // Never hard code (nor print) the api key.
  var service = FirebaseVertexAiServiceGoogle(
    apiKey: Platform.environment['GEMINI_API_KEY']!,
  );
  var vertexAi = service.vertexAi(app);

  var model = vertexAi.generativeModel(
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: Schema.object(properties: {'total': Schema.number()}),
    ),
  );
  var response = await model.generateContent([Content.text('Sum 1 and 4')]);
  print(response.text); // {"total": 5}
  // The product lives as long as the app.
  await app.delete();
}
```

## Backends

| Backend | Package (repo, path) | Service | Runs on |
|---|---|---|---|
| Google AI (api key) | `tekartik_firebase_vertex_ai_google` (firebase_vertex_ai.dart, `vertex_ai_google`) | `FirebaseVertexAiServiceGoogle(apiKey: ...)`, on a `tekartik_firebase_local` app | Dart VM |
| Flutter | `tekartik_firebase_vertex_ai_flutter` (firebase_flutter, `vertex_ai_flutter`) | `firebaseVertexAiServiceFlutter` (firebase_ai) | Flutter |

All the repos are under `https://github.com/tekartik/`.

## When to use what

* Write the shared code against `FirebaseVertexAi` (or `VaiGenerativeModel`),
  the app picks the backend.
* `generativeModel()` uses `vertexAiModelDefault` (`gemini-2.5-flash`, pinned)
  when no model is given.
* `Content.text`, `Content.data(mimeType, bytes)`, `VaiContent.multi([...])`,
  `VaiContent.model([...])` (a previous answer of the model).
* `GenerationConfig`: `temperature`, `maxOutputTokens`, `stopSequences`,
  `responseMimeType` and `responseSchema` (`Schema`, from
  `tekartik_app_json_schema`) for a JSON answer.

## Common pitfalls

* `response.text` is null when the answer has no text: check it.
* No `close()`: the product follows its app, delete the app.
* `vertexAiModelGemini1dot5Flash` is retired: Google answers an error for it.
* The api key is a secret: from the environment or a secret store, never
  printed nor committed.

The [tekartik-firebase-vertex-ai-usage skill](skills/tekartik-firebase-vertex-ai-usage/SKILL.md)
has more examples and how to write a backend.
