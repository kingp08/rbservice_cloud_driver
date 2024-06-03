import 'package:bedrive/drive/dialogs/confirm-file-deletion-dialog.dart';
import 'package:bedrive/drive/screens/destination-picker/destination-picker-state.dart';
import 'package:bedrive/drive/screens/file-list/folder-screen.dart';
import 'package:bedrive/drive/screens/file-preview/file-preview-screen.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-pages.dart';
import 'package:bedrive/drive/dialogs/show-snackbar.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

mixin FileViewTileActions {
  onTap(BuildContext context, FileEntry? fileEntry) async {
    final state = context.read<DriveState>();
    final pickerState = context.read<DestinationPickerState>();
    if (pickerState.active) {
      if (fileEntry!.type == 'folder') {
       pickerState.open(folder: FolderPage(fileEntry));
      }
    } else if (state.selectedEntries.isNotEmpty) {
      state.toggleEntry(fileEntry!);
    } else if (fileEntry!.type == 'folder') {
      if (state.activePage is TrashPage) {
        _handleFolderClickInTrash(context, state, fileEntry);
      } else {
        Navigator.of(context).pushNamed(
          FolderScreen.ROUTE,
          arguments: FolderScreenArgs(FolderPage(fileEntry)),
        );
      }
    } else {
      FilePreviewScreen.open(fileEntry);
    }
  }

  onLongPress(BuildContext context, FileEntry? fileEntry) {
    if ( ! context.read<DestinationPickerState>().active) {
      context.read<DriveState>().toggleEntry(fileEntry!);
    }
  }

  _handleFolderClickInTrash(BuildContext context, DriveState state, FileEntry? entry) async {
    final restored = await showConfirmationDialog(
        context,
        title: 'Folder is in trash',
        subtitle: 'To view this folder, you need to restore it first',
        confirmText: 'Restore'
    );
    if (restored != null && restored) {
      await state.restoreEntries([entry!.id]);
      showSnackBar(trans('Restored :name', replacements: {'name': entry.name}), context);
    }
  }
}