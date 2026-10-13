/// Gemini 1.5 flash, retired by Google.
@Deprecated('Retired model, use vertexAiModelDefault or another model')
const vertexAiModelGemini1dot5Flash = 'gemini-1.5-flash';

/// Gemini 2.5 flash
const vertexAiModelGemini2dot5Flash = 'gemini-2.5-flash';

/// Model used by `FirebaseVertexAi.generativeModel` when none is specified.
///
/// A pinned model rather than a `-latest` alias, so that behavior does not
/// change under an application that did not ask for a new model.
const vertexAiModelDefault = vertexAiModelGemini2dot5Flash;
