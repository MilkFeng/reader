import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../books_state.dart';
import 'player/epub_player.dart';
import 'reader_screen_state.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.relativePath});

  final String relativePath;

  @override
  State<StatefulWidget> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> with WidgetsBindingObserver {
  BooksState? booksState;
  ReaderScreenState? readerScreenState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    booksState = context.read<BooksState>();
  }

  @override
  void dispose() {
    booksState?.save();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      booksState?.save();
      readerScreenState?.pause();
    } else if (state == AppLifecycleState.resumed) {
      readerScreenState?.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final booksState = context.read<BooksState>();

    return ChangeNotifierProvider(
      create: (context) {
        readerScreenState = ReaderScreenState(
          booksState: booksState,
          relativePath: widget.relativePath,
        )..init();
        return readerScreenState;
      },
      child: Consumer<ReaderScreenState>(builder: (context, state, _) {
        if (!state.isReady) {
          return const Scaffold(
            body: Center(
              child: Text('正在加载中...'),
            ),
          );
        }
        return EpubPlayer();
      }),
    );
  }
}
