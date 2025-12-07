// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Voice Recorder';

  @override
  String get statusReady => 'Ready to record';

  @override
  String get statusRecording => 'Recording...';

  @override
  String statusSaved(String path) {
    return 'Saved to: $path';
  }

  @override
  String get permissionDeniedTitle => 'Permission Denied';

  @override
  String get permissionDeniedMessage =>
      'Microphone permission is required to record audio.';

  @override
  String get allRecordsTitle => 'All Records';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get uzbek => 'Uzbek';

  @override
  String get russian => 'Russian';

  @override
  String get audioFormat => 'Audio Format';

  @override
  String get formatAacLc => 'AAC (M4A)';

  @override
  String get formatOpus => 'Opus (OGG)';

  @override
  String get formatWav => 'WAV';

  @override
  String get formatPcm16bit => 'PCM 16-bit (WAV)';

  @override
  String get formatFlac => 'FLAC';
}
