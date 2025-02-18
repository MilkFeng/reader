import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'setup_screen_state.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final padding = 16.0;

    final setupScreenState = context.read<SetupScreenState>();
    return Scaffold(
      appBar: AppBar(),
      body: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 100,
                    height: 100,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    '欢迎使用',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: bottom + padding, left: padding, right: padding),
              child: Row(
                children: [
                  Spacer(),
                  FilledButton(
                    onPressed: () {
                      setupScreenState.nextPage();
                    },
                    child: Text('开始'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
