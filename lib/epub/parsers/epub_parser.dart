import 'package:collection/collection.dart';

import '../accessor/accessor.dart';
import '../model/epub.dart';
import 'container_parser.dart';
import 'package_parser.dart';

class EpubParser {
  static Future<Epub> parse(Accessor accessor) async {
    String? rootFilePath;

    if (accessor.canList) {
      // 找到 opf 文件
      final fileNames = await accessor.list();
      rootFilePath =
          fileNames!.firstWhereOrNull((name) => name.endsWith('.opf'));
    }
    if (rootFilePath == null && accessor.canCheckExist) {
      // 检查是否存在 content.opf、OEBPS/content.opf、OPS/content.opf
      final fileNames = [
        'content.opf',
        'OEBPS/content.opf',
        'OPS/content.opf',
      ];
      for (final fileName in fileNames) {
        if (await accessor.exists(fileName)) {
          rootFilePath = fileName;
          break;
        }
      }
    }
    if (rootFilePath == null) {
      final containerFile = await accessor.access('META-INF/container.xml');
      rootFilePath = await ContainerParser.parse(containerFile);
    }

    final packageFile = await accessor.access(rootFilePath);
    final (metadata, manifest, navigation) =
        await PackageParser.parse(packageFile, accessor);

    return Epub(metadata: metadata, manifest: manifest, navigation: navigation);
  }
}
