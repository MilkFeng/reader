import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';

import '../../../common/fs_utils.dart';
import '../../../epub/epub.dart';
import 'assets_service.dart';
import 'epub_service.dart';
import 'interceptor.dart';
import 'server.dart';

class _ServerParams {
  final RootIsolateToken rootIsolateToken;
  final SendPort sendPort;

  final String rootPath;
  final String epubPath;
  final String bundlePath;

  final String style;
  final String script;

  _ServerParams({
    required this.rootIsolateToken,
    required this.sendPort,
    required this.rootPath,
    required this.epubPath,
    required this.bundlePath,
    required this.style,
    required this.script,
  });
}

class Backend {
  Isolate? _serverIsolate;
  ReceivePort? _receivePort;
  int? _serverPort;

  bool _interceptorPrepared = false;
  final Interceptor interceptor = Interceptor();

  Capability? _pauseCapability;

  final String rootPath;
  final String epubPath;
  final String bundlePath;

  Backend({
    required this.rootPath,
    required this.epubPath,
    required this.bundlePath,
  });

  static Future<void> _startServer(_ServerParams params) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(params.rootIsolateToken);

    final server = Server();
    final port = await server.startServer();

    final bundleBytes = await FSUtils.readFileBytesFromJoinPath(
        params.rootPath, params.bundlePath);
    final bundle = EpubBundle.fromJson(jsonDecode(utf8.decode(bundleBytes)));

    final epubBytes = await FSUtils.readFileBytesFromJoinPath(
        params.rootPath, params.epubPath);

    final epub = EpubOpener.openBytesWithBundle(epubBytes, bundle);

    server.registerService(EpubService(
      epub,
      style: params.style,
      script: params.script,
    ));

    params.sendPort.send(port);
  }

  void _prepareInterceptor() {
    interceptor.registerService(AssetsService());
    _interceptorPrepared = true;
  }

  Future<void> start() async {
    final style = await rootBundle.loadString('assets/webview/style.css');
    final script = await rootBundle.loadString('assets/webview/javascript.js');

    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;

    _receivePort = ReceivePort();
    _serverIsolate = await Isolate.spawn(
      _startServer,
      _ServerParams(
        rootIsolateToken: rootIsolateToken,
        sendPort: _receivePort!.sendPort,
        rootPath: rootPath,
        epubPath: epubPath,
        bundlePath: bundlePath,
        style: style,
        script: script,
      ),
    );
    _serverPort = await _receivePort!.first as int;

    _prepareInterceptor();
  }

  void pause() {
    _pauseCapability = _serverIsolate?.pause();
  }

  void resume() {
    if (_pauseCapability == null) {
      return;
    }
    _serverIsolate?.resume(_pauseCapability!);
    _pauseCapability = null;
  }

  void stop() {
    _serverIsolate?.kill();
    _receivePort?.close();

    _serverIsolate = null;
    _receivePort = null;
    _serverPort = null;

    _interceptorPrepared = false;
    interceptor.clearServices();
  }

  bool get isReady =>
      _serverIsolate != null &&
      _receivePort != null &&
      _serverPort != null &&
      _interceptorPrepared;

  int get serverPort => _serverPort!;
}
