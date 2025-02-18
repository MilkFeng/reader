import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'browse_page_state.dart';

class Breadcrumbs extends StatelessWidget implements PreferredSizeWidget {
  const Breadcrumbs({super.key});

  static const double padding = 16;
  static const double fontSize = 16;

  TextStyle get textStyle => TextStyle(fontSize: fontSize);

  static double get preferredHeight {
    return padding * 2 + textSize('你好', TextStyle(fontSize: fontSize)).height;
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(preferredHeight);
  }

  static Size textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 2 * padding;

    final explorePageState = context.read<BrowsePageState>();

    return Selector<BrowsePageState, List<String>>(
      selector: (context, state) => state.currentDirectoryPathSegments,
      builder: (context, pathSegments, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: padding),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: padding),
            reverse: true,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: width),
              child: Row(
                children: pathSegments.isEmpty
                    ? const []
                    : List.generate(pathSegments.length * 2 - 1, (index) {
                        if (index.isOdd) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.chevron_right),
                          );
                        }
                        return InkWell(
                          onTap: () {
                            explorePageState.goToDirectory(index ~/ 2);
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Text(
                            pathSegments.elementAt(index ~/ 2),
                            style: index ~/ 2 == pathSegments.length - 1
                                ? textStyle.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary)
                                : textStyle,
                          ),
                        );
                      }),
              ),
            ),
          ),
        );
      },
    );
  }
}
