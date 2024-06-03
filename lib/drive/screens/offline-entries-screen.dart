import 'package:bedrive/drive/screens/file-list/file-list-container.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-pages.dart';
import 'package:bedrive/drive/state/offlined-entries/offlined-entries.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OfflineEntriesScreen extends StatefulWidget {
  static const ROUTE = 'offlineEntries';

  @override
  _OfflineEntriesScreenState createState() => _OfflineEntriesScreenState();
}

class _OfflineEntriesScreenState extends State<OfflineEntriesScreen> {

  @override
  void initState() {
    context.read<DriveState>().openPage(OfflinedPage(context.read<OfflinedEntries>()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('Offline'),
      ),
      body: FileListContainer(),
    );
  }
}
