---
name: tekartik-google-ai-image-generation
description: >-
  Use when generating or refining images with tekartik_google_ai and the gemini
  image models (Nano Banana): generativeImageModel, GaiImageConfig aspect ratio
  and size, GaiResponseModality, reading response.image / response.images, or
  diagnosing a 429 "limit: 0" failure on an image model.
---

# tekartik_google_ai image generation

Image generation is a normal `generateContent` call: an image model answers
with inline image parts instead of, or alongside, text.
`GoogleAi.generativeImageModel()` presets the modalities those models expect,
and images come back as `GaiContentDataPart`, the same type used for input, so
they can be fed straight back to refine them.

## Guidelines

* **Image generation requires a billed project.** Gemini image models are not
  on the free tier: an unbilled api key fails with `RateLimitException(429)`
  carrying `limit: 0` for every image model. That is a plan problem, not a
  rate problem, so retrying and backing off never help; the key's Google Cloud
  project needs a billing account. A Firebase project on the Blaze plan
  already has one.
* Use `generativeImageModel(...)`, do not set `responseModalities` yourself:
  it already requests `GaiResponseModality.text` and `GaiResponseModality.image`
  together, which is what image models expect. Reach for `generativeModel`
  with an explicit `GenerationConfig` only for something it does not expose.
* `response.text` is **usually null** for image models, they commonly answer
  with the image alone. Never print it unconditionally and never use `text!`.
* Always null check `response.image`; it is null when the model returned no
  image, for instance on a refused prompt. `response.images` is then empty.
* Only image models work. `generativeImageModel()` defaults to
  `googleAiModelDefaultImage` (`gemini-2.5-flash-image`); the alternatives are
  `googleAiModelGemini3dot1FlashImage` and `googleAiModelGemini3ProImage`.
  A text model asked for the image modality fails.
* `GaiImageConfig.aspectRatio` accepts `1:1`, `2:3`, `3:2`, `3:4`, `4:3`,
  `9:16`, `16:9`, `21:9`; `imageSize` accepts `1K`, `2K`, `4K` and defaults to
  `1K`. Sizes are approximate: `16:9` at `1K` comes back as 1344x768, which is
  not exactly 16:9, so never assert exact dimensions.
* Images bill **per generated image**, not per token, so a call costs far more
  than a text one. Never put image generation in a retry loop, a benchmark or
  a CI test; cover the decoding path with a fake response instead.
* `response.parts` exposes the first candidate's parts. Parts the abstraction
  does not model (thoughts, function calls, code execution) are dropped rather
  than failing the response, so thought signatures do not survive a round trip.

## Examples

### Generate and save

```dart
import 'package:tekartik_google_ai/google_ai.dart';

var googleAi = GoogleAi(apiKey: apiKey);
try {
  var model = googleAi.generativeImageModel(
    imageConfig: const GaiImageConfig(aspectRatio: '16:9'),
  );
  var response = await model.generateContent([
    Content.text('A calm lake surrounded by pine trees'),
  ]);
  var image = response.image;
  if (image != null) {
    await File('lake.png').writeAsBytes(image.bytes);
  }
} finally {
  googleAi.close();
}
```

`GaiContentDataPart` carries `mimeType`, `bytes` and `isImage`.

### Refine the generated image

Send the prompt, the generated parts as a model turn, then the edit. Without
the model turn the model draws a new image instead of editing the previous one.

```dart
var edited = await model.generateContent([
  Content.text(prompt),
  GaiContent.model(response.parts),
  Content.text('Add a small wooden cabin on the shore'),
]);
```

### Which image models a key can reach

```dart
var models = await googleAi.listModels();
var imageModels = models.where((m) => m.id.contains('image'));
```

### Keeping a full config

```dart
googleAi.generativeImageModel(
  model: googleAiModelGemini3ProImage,
  imageConfig: const GaiImageConfig(imageSize: '2K'),
  generationConfig: GenerationConfig(temperature: 0.2),
);
```

`generationConfig` passes through; only `responseModalities` and `imageConfig`
are overridden.

## Common mistakes

* Retrying a `429` whose detail says `limit: 0`: it will never succeed, the
  project is simply unbilled.
* Printing `response.text` and getting `null`, then assuming the call failed
  when the image is right there in `response.images`.
* Passing an image model to `generativeModel()` without modalities, so the
  model has no permission to answer with an image.
* Asserting the returned PNG is exactly 16:9.
