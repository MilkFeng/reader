import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/dialog.dart';
import '../../reader_screen_state.dart';
import '../style_state.dart';
import 'style_sheet.dart';

class PanelController extends ChangeNotifier {
  bool showPanel = false;

  void togglePanel() {
    showPanel = !showPanel;
    notifyListeners();
  }

  void openPanel() {
    if (!showPanel) {
      showPanel = true;
      notifyListeners();
    }
  }

  void closePanel() {
    if (showPanel) {
      showPanel = false;
      notifyListeners();
    }
  }
}

class Panel extends StatefulWidget {
  const Panel({super.key, required this.controller});

  final PanelController controller;

  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  bool showDrawer = false;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      setState(() {});
    });
  }

  static const double bottomBarHeight = 72.0;

  Widget _buildBottomPanelItem(IconData icon, String label, Function() onTap) {
    return Expanded(
      child: SizedBox(
        height: bottomBarHeight,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readerScreenState = context.read<ReaderScreenState>();

    final top = MediaQuery.of(context).viewPadding.top;
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    final backgroundColor = Theme.of(context).colorScheme.surfaceContainer;

    final topBarHeight = kToolbarHeight;

    return Stack(
      children: [
        Container(color: Colors.transparent),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedContainer(
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 300),
              transform: Matrix4.translationValues(0,
                  widget.controller.showPanel ? 0 : -(top + topBarHeight), 0),
              child: AppBar(
                toolbarHeight: topBarHeight,
                title: Text(readerScreenState.metadata.titles.first),
                backgroundColor: backgroundColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                primary: true,
              ),
            ),
            AnimatedContainer(
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 300),
              transform: Matrix4.translationValues(
                  0,
                  widget.controller.showPanel ? 0 : (bottom + bottomBarHeight),
                  0),
              child: Builder(builder: (context) {
                return Container(
                  height: bottom + bottomBarHeight,
                  color: backgroundColor,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottom),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        _buildBottomPanelItem(Icons.menu, '目录', () {
                          Scaffold.of(context).openDrawer();
                        }),
                        _buildBottomPanelItem(Icons.style, '样式', () {
                          final styleState = context.read<StyleState>();
                          showCustomModalBottomSheet(
                            context: context,
                            isDismissible: true,
                            enableDrag: false,
                            builder: (context) {
                              return ChangeNotifierProvider.value(
                                value: styleState,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        "样式",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    Expanded(child: StyleSheet()),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                        // _buildBottomPanelItem(Icons.settings, '设置', () {}),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}
