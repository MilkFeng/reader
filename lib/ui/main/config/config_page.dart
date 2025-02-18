import 'package:flutter/material.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  static NavigationDestination get destination => NavigationDestination(
    selectedIcon: Icon(Icons.settings),
    icon: Icon(Icons.settings_outlined),
    label: '设置',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Center(
        child: Text('设置页'),
      ),
    );
  }
}

List<Widget> myActionsBuilder(BuildContext context) {
  return <Widget>[];
}
