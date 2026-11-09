# firebase_vertex_ai.dart

Gemini for Dart: a platform neutral Vertex AI interface for tekartik Firebase
apps, and a standalone Google AI client.

## Packages

| Package | Path | What |
|---|---|---|
| `tekartik_firebase_vertex_ai` | [vertex_ai](vertex_ai) | the interface, a product of a Firebase app (`service.vertexAi(app)`) |
| `tekartik_firebase_vertex_ai_google` | [vertex_ai_google](vertex_ai_google) | its Google AI backend (api key, Dart VM) |
| `tekartik_google_ai` | [google_ai](google_ai) | standalone Gemini client (api key, no Firebase), model listing, image generation |

The Flutter backend of the interface (`firebase_ai`) is
`tekartik_firebase_vertex_ai_flutter`, in the `firebase_flutter` repo
(`https://github.com/tekartik/firebase_flutter`).

## Getting started

Git packages, not on pub.dev. For a CLI, a server or a test, the standalone
client:

```yaml
dependencies:
  tekartik_google_ai:
    git:
      url: https://github.com/tekartik/firebase_vertex_ai.dart
      path: google_ai
```

See the [google_ai README](google_ai/README.md), or the
[vertex_ai README](vertex_ai/README.md) when the code is part of a Firebase
app. Never hard code nor print the api key.
