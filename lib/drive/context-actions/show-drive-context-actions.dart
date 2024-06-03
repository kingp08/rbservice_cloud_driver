import 'dart:io';

import 'package:bedrive/drive/context-actions/drive-context-actions-bottom-sheet.dart';
import 'package:bedrive/drive/context-actions/drive-context-actions.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<DriveContextAction?> showDriveContextActions(List<FileEntry> entries,
    {required BuildContext context, bool hidePreview = false}) {
  final state = context.read<DriveState>();
  final onlyIncludesFolders = entries.every((e) => e.type == 'folder');
  List<DriveContextActionConfig> actions = state.activePage!.contextActions
      .map((a) => a.getConfig(context, entries))
      .toList();

  actions = actions
    ..retainWhere((a) {
      final showPreview = (a.name != DriveContextAction.preview) ||
          (!hidePreview && !onlyIncludesFolders);
      final hideOnIos = a.name == DriveContextAction.download && Platform.isIOS;
      final hasPermissions = a.permission == null ||
          entries.every((e) => e.permissions!.contains(a.permission));
      final showForMultiple = a.supportsMultipleEntries || entries.length == 1;
      return !hideOnIos && showPreview && hasPermissions && showForMultiple;
    });

  final List<ListTile> tiles = actions.map((a) {
    return ListTile(
      leading: a.icon,
      title: text(a.displayName),
      onTap: () {
        Navigator.of(context).pop(a.name);
        a.onTap();
      },
    );
  }).toList();

  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext _) {
        return DriveContextActionsBottomSheet(entries, tiles, state);
      });
}
