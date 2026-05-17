import 'text_file_picker_stub.dart'
    if (dart.library.html) 'text_file_picker_web.dart';

Future<String?> pickTextFile({String accept = '.json'}) {
  return pickTextFileImpl(accept: accept);
}
