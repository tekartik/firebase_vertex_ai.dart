import 'dart:io';
import 'package:path/path.dart';
import 'package:tekartik_google_ai/google_ai.dart';

import 'api_key.dart';

/// Generate an image, then refine it in a second turn.
///
/// Writes the images next to the current directory, prints where they landed.
Future<void> main(List<String> args) async {
  var googleAi = GoogleAi(apiKey: getGeminiApiKey());
  try {
    var model = googleAi.generativeImageModel(
      imageConfig: const GaiImageConfig(aspectRatio: '16:9'),
    );

    var prompt = 'A calm lake surrounded by pine trees';
    var response = await model.generateContent([Content.text(prompt)]);
    _writeComment(response.text);
    await _writeImage(response.image, 'generated_lake.png');

    // Refine it: send the prompt, the generated content, then the edit.
    var edited = await model.generateContent([
      Content.text(prompt),
      GaiContent.model(response.parts),
      Content.text('Add a small wooden cabin on the shore'),
    ]);
    _writeComment(edited.text);
    await _writeImage(edited.image, 'generated_lake_with_cabin.png');
  } finally {
    googleAi.close();
  }
}

/// Image models often answer with the image alone, skip the empty line then.
void _writeComment(String? text) {
  if (text != null) {
    stdout.writeln('Model: $text');
  }
}

Future<void> _writeImage(GaiContentDataPart? image, String path) async {
  if (image == null) {
    stderr.writeln('No image in the response');
    return;
  }
  path = join('.local', path);
  var file = File(path);
  file.parent.createSync(recursive: true);
  await File(path).writeAsBytes(image.bytes);
  stdout.writeln(
    'Wrote $path (${image.mimeType}, ${image.bytes.length} bytes)',
  );
}
