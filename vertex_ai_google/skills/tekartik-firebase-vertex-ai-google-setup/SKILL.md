---
name: tekartik-firebase-vertex-ai-google-setup
description: >-
  Use when wiring tekartik_firebase_vertex_ai_google, the google_generative_ai
  backend of the firebase vertex ai abstraction: FirebaseVertexAiGoogle,
  FirebaseVertexAiServiceGoogle, supplying a gemini api key, listing models, or
  deciding whether to use it rather than tekartik_google_ai.
---

# tekartik_firebase_vertex_ai_google setup

Backend that implements `tekartik_firebase_vertex_ai` on top of
`google_generative_ai`. Everything you call after construction belongs to the
abstraction, this package only wires it up.

## Guidelines

* Import `package:tekartik_firebase_vertex_ai_google/vertex_ai_google.dart`.
  It re-exports the whole abstraction (`Content`, `Schema`,
  `GenerationConfig`, ...), so one import is enough. Never import
  `package:tekartik_firebase_vertex_ai_google/src/...`; the examples do it as
  a shortcut, that is not the pattern to copy.
* `FirebaseVertexAiGoogle(apiKey: ...)` is the short path: it creates a local
  firebase app for you. Use `FirebaseVertexAiServiceGoogle(apiKey: ...)` then
  `service.vertexAi(app)` when the app already exists; that `app` must be a
  `FirebaseAppLocal`, the implementation casts to it and throws otherwise.
* Never hardcode an api key, read it from the environment. The examples use
  `dsUserEnvGetVarSync('TEKARTIK_GEMINI_API_KEY')`.
* **Pass an explicit model.** `generativeModel()` falls back to
  `vertexAiModelGemini1dot5Flash` (`gemini-1.5-flash`), which is old.
* `google_generative_ai` is **discontinued** upstream in favour of the Flutter
  only `firebase_ai`. For new pure Dart code prefer `tekartik_google_ai`,
  built on the maintained `googleai_dart`, which also adds model listing and
  image generation.
* Supported surface is exactly the abstraction's: `generateContent` with text
  and inline data parts, and `GenerationConfig` including `responseSchema`.
  No model listing, streaming, image generation, embedding or function calling.
* In `Schema`, every property is required unless named in
  `optionalProperties`; the conversion computes `requiredProperties` from that.

## Examples

### Direct, no existing app

```dart
import 'package:tekartik_firebase_vertex_ai_google/vertex_ai_google.dart';

var vertexAi = FirebaseVertexAiGoogle(apiKey: apiKey);
var model = vertexAi.generativeModel(model: 'gemini-2.5-flash');
var response = await model.generateContent([Content.text('Sum 1 and 4')]);
print(response.text);
```

### Through the service, with an existing app

```dart
var service = FirebaseVertexAiServiceGoogle(apiKey: apiKey);
var vertexAi = service.vertexAi(app); // app must be a FirebaseAppLocal
```

### Structured JSON output

```dart
vertexAi.generativeModel(
  generationConfig: GenerationConfig(
    responseMimeType: 'application/json',
    responseSchema: Schema.object(properties: {'total': Schema.number()}),
  ),
);
```

### Listing models

Neither the abstraction nor `google_generative_ai` exposes `listModels`.
`example/simple_list_models.dart` calls the generative language rest api
directly, sending the key in an `x-goog-api-key` header (not a query
parameter) and following `nextPageToken`. Copy that, or use
`tekartik_google_ai` whose `listModels()` does it for you.

## Common mistakes

* Passing a non `FirebaseAppLocal` app to `service.vertexAi(app)`.
* Relying on the default model and silently running on `gemini-1.5-flash`.
* Expecting streaming, image generation or model listing here.
