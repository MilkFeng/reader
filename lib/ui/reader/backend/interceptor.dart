import 'dart:io';

import 'service.dart';

class Interceptor {
  final Map<String, Service> _services = {};

  Future<void> handleRequest(HttpRequest request) async {
    final uri = request.uri;
    final segments = uri.pathSegments;
    final part = segments[0];
    final pathWithoutPart = uri.pathSegments.skip(1).join('/');

    // 是否有 if-modified-since
    // print("request.headers: ${request.headers}");
    if (request.headers.value('if-modified-since') != null) {
      request.response.statusCode = 304;
      request.response.close();
      return;
    }

    try {
      final service = _services[part]!;
      await service.handleRequest(pathWithoutPart, request);
    } catch (e) {
      request.response.statusCode = 404;
      request.response.write('Not found');
      request.response.close();
    }
  }

  void registerService(Service service) {
    _services[service.part] = service;
  }

  void unregisterService(String part) {
    _services.remove(part);
  }

  void clearServices() {
    _services.clear();
  }
}
