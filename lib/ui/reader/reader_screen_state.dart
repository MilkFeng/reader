import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../common/fs_utils.dart';
import '../../epub/epub.dart';
import '../../managers/meta/models.dart';
import '../../../books_state.dart';
import 'backend/backend.dart';

class _ReadEpubBundleArgs {
  final String rootPath;
  final String bundlePath;
  final RootIsolateToken rootIsolateToken;

  _ReadEpubBundleArgs({
    required this.rootPath,
    required this.bundlePath,
    required this.rootIsolateToken,
  });
}

class ReaderScreenState extends ChangeNotifier {
  PageLocation? _initialLocation;
  EpubBundle? _epubBundle;
  ExtendedBookInfo? _bookInfo;
  Navigation? _navigation;
  Metadata? _metadata;

  BooksState booksState;
  String relativePath;

  Backend? _backend;

  ReaderScreenState({
    required this.booksState,
    required this.relativePath,
  });

  static Future<EpubBundle> _readEpubBundle(_ReadEpubBundleArgs args) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(args.rootIsolateToken);

    final bundleBytes =
        await FSUtils.readFileBytesFromJoinPath(args.rootPath, args.bundlePath);
    return EpubBundle.fromJson(jsonDecode(utf8.decode(bundleBytes)));
  }

  Future<void> initEpubBundle() async {
    _epubBundle = await compute(
      _readEpubBundle,
      _ReadEpubBundleArgs(
        rootPath: booksState.rootPath,
        bundlePath: _bookInfo!.epubBundleRelativePath,
        rootIsolateToken: RootIsolateToken.instance!,
      ),
    );
    _metadata = _epubBundle!.metadataBundle.toMetadata();
    _navigation = _epubBundle!.navigationBundle.toNavigation();
  }

  Future<void> initBackend() async {
    _backend = Backend(
      rootPath: booksState.rootPath,
      epubPath: relativePath,
      bundlePath: _bookInfo!.epubBundleRelativePath,
    );

    await _backend!.start();
  }

  Future<void> init() async {
    _bookInfo = booksState.getBookInfo(relativePath);
    _initialLocation = _bookInfo!.lastReadLocation;

    await Future.wait([
      initEpubBundle(),
      initBackend(),
    ]);

    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();

    booksState.save();
    _backend?.stop();

    _backend = null;
    _epubBundle = null;
    _bookInfo = null;
    _navigation = null;
    _metadata = null;
    _initialLocation = null;
  }

  void pause() {
    _backend?.pause();
  }

  void resume() {
    _backend?.resume();
  }

  bool get isReady {
    return _backend != null &&
        _backend!.isReady &&
        _epubBundle != null &&
        _bookInfo != null &&
        _navigation != null &&
        _metadata != null &&
        _initialLocation != null;
  }

  int get serverPort => _backend!.serverPort;
  EpubBundle get epubBundle => _epubBundle!;
  Navigation get navigation => _navigation!;
  Metadata get metadata => _metadata!;
  ExtendedBookInfo get bookInfo => _bookInfo!;
  PageLocation get initialLocation => _initialLocation!;
}
