import 'package:web/web.dart' as web;

Future<void> saveFile(String path, String fileName) async {
  // On Web, 'path' is a Blob URL (blob:http://...).
  // We create an anchor element to trigger the download.
  final anchor = web.HTMLAnchorElement()
    ..href = path
    ..download = fileName;

  anchor.style.display = 'none';

  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();

  print('Triggered download for: $path');
}
