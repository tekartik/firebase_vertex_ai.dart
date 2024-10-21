import 'dart:typed_data';

/// User producer
const vaiContentRoleUser = 'user';

/// Model producer
const vaiContentRoleModel = 'model';

/// The base structured datatype containing multi-part content of a message.
class VaiContent {
  /// The producer of the content.
  ///
  /// Must be either 'user' or 'model'. Useful to set for multi-turn
  /// conversations, otherwise can be left blank or unset.
  final String? role;

  /// Ordered `Parts` that constitute a single message.
  ///
  /// Parts may have different MIME types.
  final List<VaiContentPart> parts;

  /// Constructor
  VaiContent(this.role, this.parts);

  /// Return a [Content] with [TextPart].
  factory VaiContent.text(String text) =>
      VaiContent(vaiContentRoleUser, [VaiContentTextPart(text)]);

  /// Return a [Content] with [DataPart].
  factory VaiContent.data(String mimeType, Uint8List bytes) =>
      VaiContent(vaiContentRoleUser, [VaiContentDataPart(mimeType, bytes)]);

  /// Return a [Content] with multiple [Part]s.
  factory VaiContent.multi(Iterable<VaiContentPart> parts) =>
      VaiContent(vaiContentRoleUser, [...parts]);

  /// Return a [Content] with multiple [Part]s from the model.
  factory VaiContent.model(Iterable<VaiContentPart> parts) =>
      VaiContent(vaiContentRoleModel, [...parts]);
}

/// A datatype containing media that is part of a multi-part [Content] message.
class VaiContentPart {}

/// A [Part] with the text content.
final class VaiContentTextPart implements VaiContentPart {
  /// Constructor
  VaiContentTextPart(this.text);

  /// The text content of the [Part]
  final String text;

  @override
  String toString() => 'TextPart: $text';
}

/// A [Part] with the byte content of a file.
final class VaiContentDataPart implements VaiContentPart {
  /// Constructor
  VaiContentDataPart(this.mimeType, this.bytes);

  /// File type of the [DataPart].
  /// https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/send-multimodal-prompts#media_requirements
  final String mimeType;

  /// Data contents in bytes.
  final Uint8List bytes;
  @override
  String toString() => 'DataPart: $mimeType (${bytes.length} bytes)';
}
