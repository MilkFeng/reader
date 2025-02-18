import 'package:mime/mime.dart';

class MIMEUtils {
  static const String xhtml = "application/xhtml+xml";
  static const String html = "text/html";

  static bool isHTML(String mediaType) {
    return mediaType == xhtml || mediaType == html;
  }

  static bool isHTMLByExtension(String path) {
    return path.endsWith(".html") || path.endsWith(".xhtml");
  }

  static String gaussMIMEFromName(String name) {
    return lookupMimeType(name) ?? "application/octet-stream";
  }
}