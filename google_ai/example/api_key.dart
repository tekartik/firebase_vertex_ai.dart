import 'dart:io';

import 'package:tekartik_prj_tktools/dsenv.dart';

/// Read the Google AI api key from the user environment.
///
/// Exits the process with an error message if it is not set.
String getGeminiApiKey() {
  try {
    return dsUserEnvGetVarSync('TEKARTIK_GEMINI_API_KEY');
  } catch (e) {
    stderr.writeln('Cannot find TEKARTIK_GEMINI_API_KEY');
    exit(1);
  }
}
