import 'package:bedrive/drive/dialogs/loading-dialog.dart';
import 'package:bedrive/drive/screens/destination-picker/destination-picker.dart';
import 'package:bedrive/drive/screens/destination-picker/entry-move-type.dart';
import 'package:bedrive/drive/screens/file-list/folder-screen.dart';
import 'package:bedrive/drive/state/root-navigator-key.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-pages.dart';
import 'package:bedrive/drive/dialogs/show-snackbar.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DestinationPickerState {
  List<FileEntry> targetEntries = [];
  bool disableMoveAction = false;
  bool active = false;

  Future<void> open({bool disableMoveAction = false, FolderPage? folder, List<FileEntry>? entries}) async {
    active = true;
    // if entries are passed, it's initial open of destination picker
    if (entries != null) {
      targetEntries = entries;
      this.disableMoveAction = disableMoveAction;
    }
    await rootNavigatorKey.currentState!.pushNamed(DestinationPicker.ROUTE, arguments: FolderScreenArgs(folder));
    if (entries != null) {
      reset();
    }
  }

  moveEntries(BuildContext context, EntryMoveType moveType, List<FileEntry?> targetEntries, FileEntry? destination) async {
    final drive = context.read<DriveState>();
    LoadingDialog.show(message: trans(moveType == EntryMoveType.move ? 'Moving...' : 'Copying...'));
    try {
      await drive.moveOrCopyEntries(targetEntries, destination?.id, moveType);
      reset();
      Navigator.of(context).popUntil((r) => r.settings.name != DestinationPicker.ROUTE);
    } on BackendError catch (e) {
      showSnackBar(trans(e.message), context);
    }
    LoadingDialog.hide();
    drive.deselectAll();
  }


  reset() {
    final driveState = rootNavigatorKey.currentContext!.read<DriveState>();
    targetEntries = [];
    disableMoveAction = false;
    active = false;
    driveState.deselectAll();
  }

  static canMoveEntriesTo(List<FileEntry> movingEntries, FileEntry? destination, EntryMoveType moveType) {
    // given destination is not a folder or root
    if (destination != null && destination.type != 'folder') {
      return false;
    }

    // should not be able to move folder into it's
    // own child or same folder it's already in
    return movingEntries.every((entry) {
      // entry is already in this destination
      if (moveType == EntryMoveType.move && destination?.id == entry.parentId) return false;

      // destination is a child of target
      if (destination != null && destination.path.startsWith(entry.path)) return false;

      return true;
    });
  }
}