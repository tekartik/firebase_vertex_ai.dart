# tekartik_google_ai

Standalone google ai (gemini) abstraction, mapped to
[googleai_dart](https://pub.dev/packages/googleai_dart).

Same shape as `tekartik_firebase_vertex_ai` (`Content`, `Schema`,
`GenerationConfig`, `generativeModel(...)`, `generateContent(...)`) but with no
firebase dependency: no `FirebaseApp`, no product service registration, just an
api key.

## Setup

In `pubspec.yaml`:
```yaml
  tekartik_google_ai:
    git:
      url: https://github.com/tekartik/firebase_vertex_ai.dart
      path: google_ai
```

## Usage

```dart
import 'package:tekartik_google_ai/google_ai.dart';

var googleAi = GoogleAi(apiKey: apiKey);
try {
  var model = googleAi.generativeModel(
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: Schema.object(properties: {'total': Schema.number()}),
    ),
  );
  var response = await model.generateContent([Content.text('Sum 1 and 4')]);
  print(response.text);
} finally {
  googleAi.close();
}
```

`GoogleAi` owns an http client, call `close()` when done with it.

Listing the models available to the api key:

```dart
var models = await googleAi.listModels();
for (var model in models.where((model) => model.supportsGenerateContent)) {
  print('${model.id} (${model.displayName})');
}
```

## Image generation

`generativeImageModel()` defaults to `gemini-2.5-flash-image` and asks for both
text and image modalities, which is what image models expect. Images come back
as `GaiContentDataPart` (mime type + bytes):

```dart
var model = googleAi.generativeImageModel(
  imageConfig: const GaiImageConfig(aspectRatio: '16:9'),
);
var response = await model.generateContent([
  Content.text('A calm lake surrounded by pine trees'),
]);
await File('lake.png').writeAsBytes(response.image!.bytes);
```

Feed `response.parts` back as a model turn to refine an image:

```dart
var edited = await model.generateContent([
  Content.text(prompt),
  GaiContent.model(response.parts),
  Content.text('Add a small wooden cabin on the shore'),
]);
```

Image generation is **not on the Gemini free tier**: an api key without billing
gets `RateLimitException(429)` with `limit: 0` for every image model.

Use `generativeModel` with an explicit `responseModalities` if you need
something `generativeImageModel` does not expose.

## Differences with tekartik_firebase_vertex_ai

| | `tekartik_firebase_vertex_ai` | `tekartik_google_ai` |
| --- | --- | --- |
| entry point | `FirebaseVertexAiService.vertexAi(app)` | `GoogleAiService.googleAi(options)` / `GoogleAi(apiKey: ...)` |
| prefix | `Vai` | `Gai` |
| backend | `google_generative_ai` (discontinued) | `googleai_dart` |
| lifecycle | tied to the firebase app | explicit `close()` |
| model listing | none | `listModels()` |
| image generation | none | `generativeImageModel()` |

## Example

See `example/`, they read the api key from the `TEKARTIK_GEMINI_API_KEY` user
environment variable.
