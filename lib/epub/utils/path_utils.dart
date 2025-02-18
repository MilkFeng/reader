import 'package:path/path.dart' as p;

class PathUtils {
  static String normalize(String path) {
    return p.normalize(path).replaceAll('\\', '/');
  }

  static String join(String path1, String path2) {
    return p.join(path1, path2).replaceAll('\\', '/');
  }
}
