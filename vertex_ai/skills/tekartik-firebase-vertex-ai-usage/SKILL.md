---
name: tekartik-firebase-vertex-ai-usage
description: >-
  Use when writing code against the tekartik_firebase_vertex_ai abstraction
  (FirebaseVertexAiService, FirebaseVertexAi, VaiGenerativeModel, VaiContent,
  GenerationConfig, Schema), when implementing a new backend for it, or when
  choosing between it and the standalone tekartik_google_ai package.
---

# tekartik_firebase_vertex_ai abstraction

Platform-neutral vertex ai / gemini interface, following the
`tekartik_firebase` product pattern: a `FirebaseVertexAiService` attaches a
`FirebaseVertexAi` to a `FirebaseApp`. **No backend ships here**:
`tekartik_firebase_vertex_ai_google` implements it on `google_generative_ai`.

## Guidelines

* Import only `package:tekartik_firebase_vertex_ai/vertex_ai.dart`. Never
  import `package:tekartik_firebase_vertex_ai/src/...`.
* Never instantiate the types of this package: they are interfaces. Take a
  `FirebaseVertexAi` from a backend's service, `service.vertexAi(app)`, the
  same way `firestoreService.firestore(app)` works in `tekartik_firebase`.
* Write shared code against `FirebaseVertexAi` and pass it (or the model) as a
  parameter, so a test can substitute another backend.
* The `Vai` prefix marks the abstraction's own types (`VaiContent`,
  `VaiGenerativeModel`, `VaiGenerateContentResponse`). `Content`, `TextPart`
  and `InlineDataPart` are typedefs kept for familiarity with the Google SDK.
* There is **no `close()`**: lifecycle follows the `FirebaseApp`, delete the
  app instead. This is the main difference with `tekartik_google_ai`.
* `response.text` is nullable; check it rather than using `!`.
* `generativeModel()` with no `model` falls back to whatever the backend
  chooses, currently `vertexAiModelGemini1dot5Flash`, which is old. Pass an
  explicit current model.
* The interface is deliberately small: `generateContent` with text and inline
  data parts, plus `GenerationConfig`. There is no model listing, streaming,
  image generation, embedding, token counting or function calling. Use
  `tekartik_google_ai` when you need those.

## Examples

### Generate text

```dart
import 'package:tekartik_firebase_vertex_ai/vertex_ai.dart';

var vertexAi = service.vertexAi(app);
var model = vertexAi.generativeModel(model: 'gemini-2.5-flash');
var response = await model.generateContent([Content.text('Sum 1 and 4')]);
print(response.text);
```

### Structured JSON output

`Schema` is a typedef for `JsonSchema` of `tekartik_app_json_schema`. Every
property is required unless named in `optionalProperties`.

```dart
vertexAi.generativeModel(
  generationConfig: GenerationConfig(
    responseMimeType: 'application/json',
    responseSchema: Schema.object(
      properties: {'total': Schema.number(), 'note': Schema.string()},
      optionalProperties: ['note'],
    ),
  ),
);
```

### Content parts

```dart
Content.text('hello')
Content.data('image/png', bytes)
VaiContent.multi([TextPart('Describe this'), InlineDataPart(mime, bytes)])
VaiContent.model([TextPart('previous answer')])
```

Roles are `vaiContentRoleUser` and `vaiContentRoleModel`.

### Implementing a backend

Implement `FirebaseVertexAiService` with `FirebaseProductServiceMixin` and
`FirebaseVertexAi` with `FirebaseAppProductMixin` from
`package:tekartik_firebase/firebase_mixin.dart`, cache instances with
`getInstance(app, ...)`, then map `GenerationConfig` and `Schema` onto the
native client. `tekartik_firebase_vertex_ai_google` is the worked example.

## Choosing between this and tekartik_google_ai

| | this package | `tekartik_google_ai` |
| --- | --- | --- |
| firebase | required | none |
| entry point | `service.vertexAi(app)` | `GoogleAi(apiKey: ...)` |
| lifecycle | the firebase app | explicit `close()` |
| backend | `google_generative_ai` (discontinued) | `googleai_dart` |
| model listing | no | `listModels()` |
| image generation | no | `generativeImageModel()` |

Prefer `tekartik_google_ai` for a pure Dart CLI, server or test. Use this one
when the app is already a firebase app and products share its lifecycle.
