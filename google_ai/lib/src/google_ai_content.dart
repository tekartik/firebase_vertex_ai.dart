import 'dart:typed_data';

/// User producer
const gaiContentRoleUser = 'user';

/// Model producer
const gaiContentRoleModel = 'model';

/// Standard api
typedef Content = GaiContent;

/// The base structured datatype containing multi-part content of a message.
class GaiContent {
  /// The producer of the content.
  ///
  /// Must be either 'user' or 'model'. Useful to set for multi-turn
  /// conversations, otherwise can be left blank or unset.
  final String? role;

  /// Ordered `Parts` that constitute a single message.
  ///
  /// Parts may have different MIME types.
  final List<GaiContentPart> parts;

  /// Constructor
  GaiContent(this.role, this.parts);

  /// Return a [Content] with [TextPart].
  factory GaiContent.text(String text) =>
      GaiContent(gaiContentRoleUser, [GaiContentTextPart(text)]);

  /// Return a [Content] with [InlineDataPart].
  factory GaiContent.data(String mimeType, Uint8List bytes) =>
      GaiContent(gaiContentRoleUser, [GaiContentDataPart(mimeType, bytes)]);

  /// Return a [Content] with multiple parts.
  factory GaiContent.multi(Iterable<GaiContentPart> parts) =>
      GaiContent(gaiContentRoleUser, [...parts]);

  /// Return a [Content] with multiple parts from the model.
  factory GaiContent.model(Iterable<GaiContentPart> parts) =>
      GaiContent(gaiContentRoleModel, [...parts]);
}

/// A datatype containing media that is part of a multi-part [Content] message.
///
/// Sealed, the supported parts are [GaiContentTextPart] and
/// [GaiContentDataPart].
sealed class GaiContentPart {}

/// A part with the text content.
typedef TextPart = GaiContentTextPart;

/// A part with the text content.
final class GaiContentTextPart implements GaiContentPart {
  /// Constructor
  GaiContentTextPart(this.text);

  /// The text content of the part.
  final String text;

  @override
  String toString() => 'TextPart: $text';
}

/// A part with the byte content of a file.
typedef InlineDataPart = GaiContentDataPart;

/// A part with the byte content of a file.
final class GaiContentDataPart implements GaiContentPart {
  /// Constructor
  GaiContentDataPart(this.mimeType, this.bytes);

  /// File type of the [InlineDataPart].
  /// https://ai.google.dev/gemini-api/docs/prompting_with_media
  final String mimeType;

  /// Data contents in bytes.
  final Uint8List bytes;

  /// True if [mimeType] denotes an image, such as `image/png`.
  bool get isImage => mimeType.startsWith('image/');

  @override
  String toString() => 'DataPart: $mimeType (${bytes.length} bytes)';
}
