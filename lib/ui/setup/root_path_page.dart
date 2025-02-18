import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/fs_utils.dart';
import '../../settings_state.dart';
import 'setup_screen_state.dart';

class RootPathPage extends StatefulWidget {
  const RootPathPage({super.key});

  @override
  State<RootPathPage> createState() => _RootPathPageState();
}

class _RootPathPageState extends State<RootPathPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final setupScreenState = context.watch<SetupScreenState>();
    final settingsState = context.watch<SettingsState>();

    final bottom = MediaQuery.of(context).padding.bottom;
    final padding = 16.0;
    final logoSize = 65.0;

    final String? rootPath;
    if (setupScreenState.rootPath != null &&
        setupScreenState.rootPath!.isNotEmpty) {
      rootPath = setupScreenState.rootPath!;
    } else {
      rootPath = null;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setupScreenState.previousPage();
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: padding,
          bottom: bottom + padding,
          left: padding,
          right: padding,
        ),
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.vertical,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.folder,
                  size: logoSize,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 32),
                Text(
                  '设置根目录',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                SizedBox(height: 24),
                Text(
                  '请设置您的书籍根目录，我们将在这里查找您的书籍。',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            if (rootPath != null)
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: FutureBuilder(
                    future: FSUtils.listDirectory(settingsState.rootEntity),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done ||
                          !snapshot.hasData ||
                          snapshot.data == null) {
                        return SizedBox();
                      }

                      final files = snapshot.data!;

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(files[index].name),
                            leading: files[index].isFile
                                ? const Icon(Icons.file_present)
                                : const Icon(Icons.folder),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            Row(
              children: [
                if (rootPath != null)
                  TextButton(
                    onPressed: () async {
                      await settingsState.pickRootPath();
                    },
                    child: Text('重新选择根目录'),
                  ),
                if (rootPath != null) Spacer(),
                Expanded(
                  child: rootPath == null
                      ? FilledButton(
                          onPressed: () async {
                            await settingsState.pickRootPath();
                          },
                          child: Text('选择根目录'),
                        )
                      : FilledButton(
                          onPressed: () async {
                            await setupScreenState.nextPage();
                          },
                          child: Text('下一步'),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
