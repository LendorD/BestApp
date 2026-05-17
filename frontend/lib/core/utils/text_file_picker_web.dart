// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

Future<String?> pickTextFileImpl({String accept = '.json'}) {
  final completer = Completer<String?>();
  final input = html.FileUploadInputElement()..accept = accept;

  late final StreamSubscription<html.Event> changeSub;
  late final StreamSubscription<html.Event> focusSub;

  void finish(String? value) {
    if (completer.isCompleted) {
      return;
    }
    changeSub.cancel();
    focusSub.cancel();
    completer.complete(value);
  }

  changeSub = input.onChange.listen((_) {
    final file = input.files?.first;
    if (file == null) {
      finish(null);
      return;
    }

    final reader = html.FileReader();
    reader.onLoadEnd.listen((_) => finish(reader.result as String?));
    reader.onError.listen((_) => finish(null));
    reader.readAsText(file);
  });

  focusSub = html.window.onFocus.listen((_) {
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if ((input.files?.isEmpty ?? true) && !completer.isCompleted) {
        finish(null);
      }
    });
  });

  input.click();
  return completer.future;
}
