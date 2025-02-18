import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../settings_state.dart';

class SetupScreenState extends ChangeNotifier {
  int _currentPage = 0;
  String? _rootPath;

  final PageController pageController = PageController();

  int get currentPage => _currentPage;

  String? get rootPath => _rootPath;

  set rootPath(String? path) {
    _rootPath = path;
    notifyListeners();
  }

  Future<void> nextPage() async {
    _currentPage++;
    await pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.ease);

    notifyListeners();
  }

  Future<void> previousPage() async {
    _currentPage--;
    await pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.ease);

    notifyListeners();
  }

  Future<void> finish(BuildContext context) async {
    context.read<SettingsState>().setIsInitialized(true);
    await Navigator.of(context).pushReplacementNamed('/');

    notifyListeners();
  }
}
