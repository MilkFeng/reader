import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ui/app.dart';
import 'books_state.dart';
import 'settings_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsState = SettingsState();
  await settingsState.init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settingsState),
      ChangeNotifierProxyProvider<SettingsState, BooksState>(
          create: (_) => BooksState(rootPath: settingsState.rootPath!),
          update: (_, config, oldBooksState) {
            if (oldBooksState == null) {
              return BooksState(rootPath: config.rootPath!);
            } else if (oldBooksState.rootPath != config.rootPath) {
              oldBooksState.dispose();
              return BooksState(rootPath: config.rootPath!);
            } else {
              return oldBooksState;
            }
          }),
    ],
    child: const App(),
  ));
}
