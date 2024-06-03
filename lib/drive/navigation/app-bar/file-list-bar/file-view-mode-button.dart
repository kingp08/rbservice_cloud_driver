import 'package:bedrive/drive/screens/file-list/file-list-mode.dart';
import 'package:bedrive/drive/state/preference-state.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/utils/text.dart';
import 'package:provider/provider.dart';

class FileViewModeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentMode = context.select((PreferenceState s) => s.fileListMode);
    final nextMode = currentMode == FileListMode.grid ? FileListMode.list : FileListMode.grid;
    final nextIcon = currentMode == FileListMode.grid ? Icons.view_agenda_outlined : Icons.grid_view;
    final nextTooltip = currentMode == FileListMode.grid ? 'View as list' : 'View as grid';
    return IconButton(
      icon: Icon(nextIcon),
      tooltip: trans(nextTooltip),
      onPressed: () {
        context.read<PreferenceState>().setFileListMode(nextMode);
      }
    );
  }
}
