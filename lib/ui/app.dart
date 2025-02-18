import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_transitions/go_transitions.dart';
import 'package:provider/provider.dart';

import '../../ui/category/category_screen.dart';
import '../settings_state.dart';
import 'detail/detail_screen.dart';
import 'main/main_screen.dart';
import 'reader/reader_screen.dart';
import 'setup/setup_screen.dart';

class _AppBarTheme extends AppBarTheme {
  final ColorScheme colors;
  final TextTheme textTheme;

  const _AppBarTheme(this.colors, this.textTheme)
      : super(
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
          titleSpacing: NavigationToolbar.kMiddleSpacing,
          toolbarHeight: kToolbarHeight,
        );

  @override
  Color? get backgroundColor => colors.surface;

  @override
  Color? get foregroundColor => colors.onSurface;

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  IconThemeData? get iconTheme => IconThemeData(
        color: colors.onSurface,
        size: 24.0,
      );

  @override
  IconThemeData? get actionsIconTheme => IconThemeData(
        color: colors.onSurfaceVariant,
        size: 24.0,
      );

  @override
  TextStyle? get toolbarTextStyle => textTheme.titleMedium;
}

class App extends StatelessWidget {
  const App({super.key});

  ThemeData _theme(BuildContext context, bool dark) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color.fromARGB(255, 19, 71, 46),
      // seedColor: Colors.brown,
      brightness: dark ? Brightness.dark : Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    );
    final textTheme = Theme.of(context).textTheme;

    final appBarTheme = _AppBarTheme(colorScheme, textTheme);
    final pageTransition = GoTransitions.cupertino.copyWith(
      settings: GoTransitions.cupertino.settings.copyWith(
        duration: const Duration(milliseconds: 500),
      ),
    );
    final pageTransitionsTheme = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: pageTransition,
        TargetPlatform.iOS: pageTransition,
      },
    );
    final inputDecorationTheme = InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
    );
    final scrollbarTheme = ScrollbarThemeData(
      thickness: WidgetStateProperty.all(8.0),
      radius: Radius.circular(4.0),
      crossAxisMargin: 0.0,
      mainAxisMargin: 0.0,
      interactive: true,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: appBarTheme,
      pageTransitionsTheme: pageTransitionsTheme,
      inputDecorationTheme: inputDecorationTheme,
      scrollbarTheme: scrollbarTheme,
      sliderTheme: SliderThemeData(year2023: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Theme.of(context).brightness,
    ));

    final theme = _theme(context, false);
    final darkTheme = _theme(context, true);

    return Consumer<SettingsState>(
      builder: (context, settingsState, _) {
        if (settingsState.rootPath == null) {
          return const SizedBox();
        }

        return MaterialApp(
          title: 'Reader',
          themeMode: ThemeMode.system,
          theme: theme,
          darkTheme: darkTheme,
          onGenerateInitialRoutes: (initialRoute) {
            final settingsState = context.watch<SettingsState>();
            if (settingsState.isInitialized != true) {
              return [
                MaterialPageRoute(
                  settings: RouteSettings(name: '/setup'),
                  builder: (context) => const SetupScreen(),
                )
              ];
            } else {
              return [
                MaterialPageRoute(
                  settings: RouteSettings(name: '/'),
                  builder: (context) => const MainScreen(),
                )
              ];
            }
          },
          routes: {
            '/': (context) => const MainScreen(),
            '/setup': (context) => const SetupScreen(),
            '/detail': (context) {
              final relativePath =
                  ModalRoute.of(context)!.settings.arguments as String;
              return DetailScreen(relativePath: relativePath);
            },
            '/reader': (context) {
              final relativePath =
                  ModalRoute.of(context)!.settings.arguments as String;
              return ReaderScreen(relativePath: relativePath);
            },
            '/category': (context) => const CategoryManageScreen(),
          },
        );
      },
    );
  }
}
