import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../settings_state.dart';
import 'complete_page.dart';
import 'root_path_page.dart';
import 'setup_screen_state.dart';
import 'start_page.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProxyProvider<SettingsState, SetupScreenState>(
      create: (_) => SetupScreenState(),
      update: (_, settingsState, setupState) {
        setupState!.rootPath = settingsState.rootPath;
        return setupState;
      },
      child: Consumer<SetupScreenState>(
        builder: (context, setupScreenState, _) {
          return PopScope(
            onPopInvokedWithResult: (didPop, result) {
              if (setupScreenState.currentPage == 0) {
                Navigator.of(context).pop();
              } else {
                setupScreenState.previousPage();
              }
            },
            canPop: false,
            child: PageView(
              controller: setupScreenState.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                StartPage(),
                RootPathPage(),
                CompletePage(),
              ],
            ),
          );
        },
      ),
    );
  }
}
