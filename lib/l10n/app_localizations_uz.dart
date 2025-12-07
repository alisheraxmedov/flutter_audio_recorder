// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Ovoz Yozuvchisi';

  @override
  String get statusReady => 'Yozishga tayyor';

  @override
  String get statusRecording => 'Yozilmoqda...';

  @override
  String statusSaved(String path) {
    return 'Saqlandi: $path';
  }

  @override
  String get permissionDeniedTitle => 'Ruxsat etilmadi';

  @override
  String get permissionDeniedMessage =>
      'Ovoz yozish uchun mikrofonga ruxsat kerak.';

  @override
  String get allRecordsTitle => 'Barcha yozuvlar';

  @override
  String get settingsTitle => 'Sozlamalar';

  @override
  String get language => 'Til';

  @override
  String get english => 'Ingliz tili';

  @override
  String get uzbek => 'O‘zbek tili';

  @override
  String get russian => 'Rus tili';

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
