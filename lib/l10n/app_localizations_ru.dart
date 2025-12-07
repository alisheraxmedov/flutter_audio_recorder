// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Диктофон';

  @override
  String get statusReady => 'Готов к записи';

  @override
  String get statusRecording => 'Запись...';

  @override
  String statusSaved(String path) {
    return 'Сохранено в: $path';
  }

  @override
  String get permissionDeniedTitle => 'Отказано в доступе';

  @override
  String get permissionDeniedMessage =>
      'Для записи звука требуется разрешение микрофона.';

  @override
  String get allRecordsTitle => 'Все записи';

  @override
  String get settingsTitle => 'Настройки';
}
