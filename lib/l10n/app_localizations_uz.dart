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
}
