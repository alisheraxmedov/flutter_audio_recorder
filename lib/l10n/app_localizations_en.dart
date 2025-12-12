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

  @override
  String get noRecordsFound => 'No records found';

  @override
  String get deleteRecordingTitle => 'Delete Recording?';

  @override
  String deleteRecordingMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get renameRecording => 'Rename Recording';

  @override
  String get enterNewName => 'Enter new name';

  @override
  String get rename => 'Rename';

  @override
  String get sortTitle => 'Sort';

  @override
  String get sortDateNew => 'Newest';

  @override
  String get sortDateOld => 'Oldest';

  @override
  String get sortNameAsc => 'A-Z';

  @override
  String get sortNameDesc => 'Z-A';

  @override
  String get newFolder => 'New Folder';

  @override
  String get folderName => 'Folder Name';

  @override
  String get create => 'Create';

  @override
  String get moveTo => 'Move to...';

  @override
  String get extractFromFolder => 'Parent folder';

  @override
  String get noFolders => 'No folders';
}
