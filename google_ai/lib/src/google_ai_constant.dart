/// Gemini 2.5 flash
const googleAiModelGemini2dot5Flash = 'gemini-2.5-flash';

/// Gemini 2.5 pro
const googleAiModelGemini2dot5Pro = 'gemini-2.5-pro';

/// Always the current flash model, may change over time.
const googleAiModelGeminiFlashLatest = 'gemini-flash-latest';

/// Always the current pro model, may change over time.
const googleAiModelGeminiProLatest = 'gemini-pro-latest';

/// Model used by [GoogleAi.generativeModel] when none is specified.
///
/// A pinned model rather than a `-latest` alias, so that behavior does not
/// change under an application that did not ask for a new model.
const googleAiModelDefault = googleAiModelGemini2dot5Flash;

/// Gemini 2.5 flash image, aka "Nano Banana".
const googleAiModelGemini2dot5FlashImage = 'gemini-2.5-flash-image';

/// Gemini 3.1 flash image, aka "Nano Banana 2".
const googleAiModelGemini3dot1FlashImage = 'gemini-3.1-flash-image';

/// Gemini 3 pro image, aka "Nano Banana Pro".
const googleAiModelGemini3ProImage = 'gemini-3-pro-image';

/// Model used by [GoogleAi.generativeImageModel] when none is specified.
const googleAiModelDefaultImage = googleAiModelGemini2dot5FlashImage;
