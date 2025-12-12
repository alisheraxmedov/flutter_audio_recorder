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

  @override
  String get language => 'Язык';

  @override
  String get english => 'Английский';

  @override
  String get uzbek => 'Узбекский';

  @override
  String get russian => 'Русский';

  @override
  String get audioFormat => 'Формат аудио';

  @override
  String get formatAacLc => 'AAC (M4A)';

  @override
  String get formatOpus => 'Opus (OGG)';

  @override
  String get formatWav => 'WAV';

  @override
  String get formatPcm16bit => 'PCM 16-бит (WAV)';

  @override
  String get formatFlac => 'FLAC';

  @override
  String get noRecordsFound => 'Записей пока нет';

  @override
  String get deleteRecordingTitle => 'Удалить запись?';

  @override
  String deleteRecordingMessage(String name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get renameRecording => 'Переименовать запись';

  @override
  String get enterNewName => 'Введите новое имя';

  @override
  String get rename => 'Переименовать';

  @override
  String get sortTitle => 'Сортировка';

  @override
  String get sortDateNew => 'Новые';

  @override
  String get sortDateOld => 'Старые';

  @override
  String get sortNameAsc => 'А-Я';

  @override
  String get sortNameDesc => 'Я-А';

  @override
  String get newFolder => 'Новая папка';

  @override
  String get folderName => 'Имя папки';

  @override
  String get create => 'Создать';

  @override
  String get moveTo => 'Переместить...';

  @override
  String get extractFromFolder => 'Родительская папка';

  @override
  String get noFolders => 'Нет папок';
}
