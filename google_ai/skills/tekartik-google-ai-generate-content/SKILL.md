---
name: tekartik-google-ai-generate-content
description: >-
  Use when generating text or structured JSON with tekartik_google_ai, the
  standalone gemini client with no firebase dependency: GoogleAi,
  GoogleAiService, generativeModel, generateContent, GaiContent/Content parts,
  GenerationConfig, responseSchema, listModels and model constants.
---

# tekartik_google_ai content generation

Pure Dart gemini client built on `googleai_dart`, with the same shape as the
`tekartik_firebase_vertex_ai` abstraction but no firebase: no `FirebaseApp`,
no product service, just an api key and an explicit `close()`. Use it for
CLIs, servers and tests; use `tekartik_firebase_vertex_ai` instead when the
app is already a firebase app.

## Guidelines

* Import only `package:tekartik_google_ai/google_ai.dart`. Never import
  `package:tekartik_google_ai/src/...`: the `Impl` classes
  (`GaiGenerativeModelImpl`, `GaiGenerateContentResponseImpl`) and the
  `toNative...` conversions live there and are deliberately not exported.
* Create the client with `GoogleAi(apiKey: ...)`, a shortcut for
  `googleAiService.googleAi(GoogleAiOptions(apiKey: apiKey))`. Reuse one
  instance for many models and requests, one per api key, never one per call.
* `GoogleAi` owns an http client: always `close()` it in a `finally`. Nothing
  else manages its lifecycle, unlike the firebase variant where the app does.
  The instance must not be used after `close()`.
* Never hardcode an api key. Read it from the environment, for instance
  `dsUserEnvGetVarSync('TEKARTIK_GEMINI_API_KEY')` as the examples do.
* Omit `model` to get `googleAiModelDefault` (`gemini-2.5-flash`), or pass a
  constant: `googleAiModelGemini2dot5Flash`, `googleAiModelGemini2dot5Pro`,
  `googleAiModelGeminiFlashLatest`, `googleAiModelGeminiProLatest`. Prefer a
  pinned model over a `-latest` alias so behaviour does not shift under you.
* `response.text` is **nullable** and is the concatenation of every text part
  of every candidate. Check it, never `response.text!`, it is null whenever
  the answer carries no text part (routine for image models).
* `Content` is a typedef for `GaiContent`, `TextPart` for `GaiContentTextPart`
  and `InlineDataPart` for `GaiContentDataPart`. `GaiContentPart` is sealed:
  only text and inline data exist. There is no streaming, function calling,
  embedding or token counting in this abstraction; drop to `googleai_dart`
  directly for those.
* `GenerationConfig` is immutable and has no `copyWith`: build a new one
  rather than trying to mutate it.
* Exceptions are `googleai_dart` exceptions, passed through unwrapped. To
  catch them (`RateLimitException`, `GoogleAIException`) import
  `package:googleai_dart/googleai_dart.dart` as well.

## Examples

### Plain text

```dart
import 'package:tekartik_google_ai/google_ai.dart';

var googleAi = GoogleAi(apiKey: apiKey);
try {
  var model = googleAi.generativeModel();
  var response = await model.generateContent([Content.text('Sum 1 and 4')]);
  stdout.writeln(response.text);
} finally {
  googleAi.close();
}
```

### Structured JSON output

`Schema` is a typedef for `JsonSchema` of `tekartik_app_json_schema`. Every
property is required unless named in `optionalProperties`.

```dart
var model = googleAi.generativeModel(
  generationConfig: GenerationConfig(
    responseMimeType: 'application/json',
    responseSchema: Schema.object(
      properties: {'total': Schema.number(), 'note': Schema.string()},
      optionalProperties: ['note'],
    ),
  ),
);
var response = await model.generateContent([Content.text('Sum 1 and 4')]);
var map = jsonDecode(response.text!) as Map<String, Object?>;
```

Builders: `Schema.object`, `Schema.array`, `Schema.string`, `Schema.number`,
`Schema.integer`, `Schema.boolean`, `Schema.enumString`.

### Multi turn

```dart
await model.generateContent([
  Content.text('Who wrote Hamlet?'),
  GaiContent.model([TextPart('Shakespeare.')]),
  Content.text('When?'),
]);
```

Roles are `gaiContentRoleUser` and `gaiContentRoleModel`.

### Bytes in a prompt

```dart
await model.generateContent([
  GaiContent.multi([
    TextPart('Describe this image'),
    InlineDataPart('image/png', bytes),
  ]),
]);
```

### Listing models

```dart
var models = await googleAi.listModels();
for (var info in models.where((m) => m.supportsGenerateContent)) {
  stdout.writeln('${info.id} ${info.displayName}');
}
```

`listModels()` follows pagination itself. Pass `GaiModelInfo.id` (no prefix)
as `model`; `GaiModelInfo.name` keeps the `models/` prefix.

## Common mistakes

* Forgetting `close()`, leaking the http client and hanging a CLI.
* `response.text!` on an image or refused response.
* Setting `responseSchema` without `responseMimeType: 'application/json'`,
  which silently ignores the schema.
* Expecting `optionalProperties` to declare what is required: it is the
  opposite, it subtracts from the required set.
* Reaching into `src/` for an `Impl` class instead of the interface.
