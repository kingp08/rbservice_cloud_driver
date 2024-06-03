import 'package:bedrive/drive/screens/file-list/file-list-container.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-pages.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrashScreen extends StatefulWidget {
  static const ROUTE = 'trash';

  @override
  _TrashScreenState createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {

  @override
  void initState() {
    context.read<DriveState>().openPage(TrashPage());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('Trash'),
      ),
      body: FileListContainer(),
    );
  }
}
