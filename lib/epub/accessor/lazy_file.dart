import 'dart:typed_data';

abstract class LazyFile {
  String get path;
  String get name;
  String get dirPath;

  String get extension {
    if (name.contains('.')) {
      return name.split('.').last;
    } else {
      return '';
    }
  }

  Future<bool> get loaded;
  Future<Uint8List> get bytes;

  Future<void> close();
}