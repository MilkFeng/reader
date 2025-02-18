import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'setup_screen_state.dart';

class CompletePage extends StatelessWidget {
  const CompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final padding = 16.0;

    final setupScreenState = context.read<SetupScreenState>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setupScreenState.previousPage();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.done_all,
                    size: 100,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  SizedBox(height: 32),
                  Text(
                    '初始化完成',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ),
            Padding(
                padding:
                    EdgeInsets.only(bottom: bottom + padding, left: padding, right: padding),
                child: Row(
                  children: [
                    Spacer(),
                    FilledButton(
                      onPressed: () {
                        setupScreenState.finish(context);
                      },
                      child: Text('完成'),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
