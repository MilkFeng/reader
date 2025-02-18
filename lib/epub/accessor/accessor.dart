import 'lazy_file.dart';

abstract class Accessor {
  bool get canCheckExist;
  Future<bool> exists(String path);

  Future<LazyFile> access(String path);

  bool get canList;
  Future<List<String>?> list();

  void dispose();
}
