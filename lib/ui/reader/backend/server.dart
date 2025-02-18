import 'dart:io';

import 'interceptor.dart';
import 'service.dart';

class Server {
  final Interceptor _interceptor = Interceptor();
  HttpServer? _server;

  void registerService(Service service) {
    _interceptor.registerService(service);
  }

  Future<int> startServer({
    int port = 0,
  }) async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server!.listen(_interceptor.handleRequest);

    return _server!.port;
  }

  Future<void> stopServer() async {
    await _server?.close();
    _server = null;
  }
}
