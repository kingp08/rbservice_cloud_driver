import 'package:bedrive/drive/context-actions/drive-context-actions.dart';
import 'package:bedrive/drive/context-actions/show-drive-context-actions.dart';
import 'package:bedrive/drive/state/entry-cache.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/utils/text.dart';
import 'package:provider/provider.dart';

class SelectionModeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedIds = context.select((DriveState s) => s.selectedEntries);
    final cache = context.watch<EntryCache>();
    final selectedEntries =
        selectedIds.map((id) => cache.get(id)).whereType<FileEntry>().toList();
    final moveAction =
        DriveContextAction.move.getConfig(context, selectedEntries);

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          context.read<DriveState>().deselectAll();
        },
      ),
      title: text(':count Selected',
          replacements: {'count': selectedEntries.length.toString()},
          weight: FontWeight.normal,
          size: 18),
      actions: [
        IconButton(
          icon: moveAction.icon!,
          tooltip: trans(moveAction.displayName),
          onPressed: moveAction.onTap,
        ),
        IconButton(
            icon: const Icon(Icons.select_all_outlined),
            tooltip: trans('Select all'),
            onPressed: () async {
              context.read<DriveState>().selectAll();
            }),
        IconButton(
            icon: const Icon(Icons.more_vert_outlined),
            onPressed: () async {
              showDriveContextActions(selectedEntries, context: context);
            }),
      ],
    );
  }
}
