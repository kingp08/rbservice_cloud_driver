import 'dart:io';
import 'package:bedrive/auth/auth-state.dart';
import 'package:bedrive/config/app-config.dart';
import 'package:bedrive/drive/dialogs/crupdate-entry-dialog.dart';
import 'package:bedrive/drive/dialogs/show-message-dialog.dart';
import 'package:bedrive/drive/dialogs/show-snackbar.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/screens/destination-picker/destination-picker-state.dart';
import 'package:bedrive/drive/screens/file-preview/file-preview-screen.dart';
import 'package:bedrive/drive/screens/manage-users/manage-users-screen.dart';
import 'package:bedrive/drive/screens/shareable-link/shareable-link-screen.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/file-pages.dart';
import 'package:bedrive/drive/state/offlined-entries/offlined-entries.dart';
import 'package:bedrive/drive/state/root-navigator-key.dart';
import 'package:bedrive/transfers/transfer-queue/transfer-queue.dart';
import 'package:bedrive/transfers/transfers-screen/transfers-screen.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

enum DriveContextAction {
  preview,
  manageUsers,
  shareableLink,
  toggleStarred,
  rename,
  move,
  delete,
  restore,
  deleteForever,
  unshare,
  copyToOwnDrive,
  download,
  toggleOfflined,
}

extension GetContextAction on DriveContextAction {
  // ignore: missing_return
  DriveContextActionConfig getConfig(BuildContext context, List<FileEntry> entries) {
    switch (this) {
      case DriveContextAction.preview:
        return _Preview(context, entries);
      case DriveContextAction.manageUsers:
        return _ManageUsers(context, entries);
      case DriveContextAction.shareableLink:
        return _ShareableLink(context, entries);
      case DriveContextAction.toggleStarred:
        return _ToggleStarred(context, entries);
      case DriveContextAction.rename:
        return _Rename(context, entries);
      case DriveContextAction.move:
        return _Move(context, entries);
      case DriveContextAction.copyToOwnDrive:
        return _CopyToOwnDrive(context, entries);
      case DriveContextAction.delete:
        return _Delete(context, entries);
      case DriveContextAction.restore:
        return _Restore(context, entries);
      case DriveContextAction.deleteForever:
        return _DeleteForever(context, entries);
      case DriveContextAction.unshare:
        return _Unshare(context, entries);
      case DriveContextAction.download:
        return _Download(context, entries);
      case DriveContextAction.toggleOfflined:
        return _ToggleOfflined(context, entries);
    }
  }
}

abstract class DriveContextActionConfig {
  DriveContextActionConfig({
    required this.name,
    required this.entries,
    required this.context,
    this.icon,
    this.displayName,
    this.permission,
    this.supportsMultipleEntries = false,
  });
  Icon? icon;
  String? displayName;
  DriveContextAction name;
  final List<FileEntry> entries;
  final BuildContext context;
  EntryPermission? permission;
  bool supportsMultipleEntries;
  void onTap();

  DriveState get driveState => rootNavigatorKey.currentContext!.read<DriveState>();
}

class _Download extends DriveContextActionConfig {
  _Download(BuildContext context, List<FileEntry> entries)
      : super(
    supportsMultipleEntries: true,
    permission: EntryPermission.download,
    icon: const Icon(Icons.download_outlined),
    name: DriveContextAction.download,
    displayName: 'Download',
    context: context,
    entries: entries,
  );

  onTap() async {
    final transfers = context.read<TransferQueue>();
    final appName = context.read<AppConfig>().appName;
    String? destination;
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      // no need to ask for a permission in later android versions
      if (info.version.sdkInt > 28) {
        destination = '/storage/emulated/0/Download';
      } else {
        if (await Permission.storage.request().isGranted) {
          destination = '/storage/emulated/0/Download';
        } else {
          showMessageDialog(context, trans('$appName needs storage permissions in order to download files. You can grant this permission from app settings.'));
        }
      }
    } else {
      destination = (await getApplicationDocumentsDirectory()).path;
    }
    if (destination != null) {
      entries.forEach((entry) {
        transfers.addDownload(entry, '$destination/${entry.name}');
      });
      driveState.deselectAll();
      showSnackBar(
        trans('Queued :count items for download.', replacements: {'count': entries.length.toString()}),
        context,
        action: SnackBarAction(label: trans('View')!, onPressed: () {
          rootNavigatorKey.currentState!.pushNamed(TransfersScreen.ROUTE);
        }),
      );
    }
  }
}

class _Preview extends DriveContextActionConfig {
  _Preview(BuildContext context, List<FileEntry> entries)
      : super(
    icon: const Icon(Icons.remove_red_eye_outlined),
    name: DriveContextAction.preview,
    displayName: 'Preview',
    context: context,
    entries: entries,
  );

  onTap() {
    FilePreviewScreen.open(entries[0]);
  }
}

class _ManageUsers extends DriveContextActionConfig {
  _ManageUsers(BuildContext context, List<FileEntry> entries) : super(
    context: context,
    entries: entries,
    icon: const Icon(Icons.group_add_outlined),
    name: DriveContextAction.manageUsers,
    displayName: 'Manage Collaborators',
    permission: EntryPermission.update,
  );

  onTap() {
    Navigator.of(context).pushNamed(ManageUsersScreen.ROUTE, arguments: ManageUsersArgs(entries.first));
  }
}

class _ShareableLink extends DriveContextActionConfig {
  _ShareableLink(BuildContext context, List<FileEntry> entries) : super(
    context: context,
    entries: entries,
    icon: const Icon(Icons.link_outlined),
    name: DriveContextAction.shareableLink,
    displayName: 'Get Shareable Link',
    permission: EntryPermission.update,
  );

  onTap() {
    Navigator.of(context).pushNamed(ShareableLinkScreen.ROUTE, arguments: ShareableLinkArgs(entries.first));
  }
}

class _ToggleStarred extends DriveContextActionConfig {
  _ToggleStarred(BuildContext context, List<FileEntry> entries) : super(
    context: context,
    entries: entries,
    supportsMultipleEntries: true,
    name: DriveContextAction.toggleStarred,
  ) {
    final allStarred = entries.every((e) => e.isStarred());
    this.displayName = allStarred ? 'Remove from Starred' : 'Add to Starred';
    this.icon = allStarred ? Icon(Icons.star_outline, color: Colors.orange) : Icon(Icons.star);
  }

  onTap() async {
    if (entries[0].isStarred()) {
      try {
        await context.read<DriveState>().removeFromStarred(entries.map((e) => e.id).toList());
        showSnackBar(trans('Removed from starred'), context);
      } on BackendError catch(e) {
        showSnackBar(trans(e.message), context);
      }
    } else {
      try {
        await context.read<DriveState>().addToStarred(entries.map((e) => e.id).toList());
        showSnackBar(trans('Added to starred'), context);
      } on BackendError catch(e) {
        showSnackBar(trans(e.message), context);
      }
    }
  }
}

class _Rename extends DriveContextActionConfig {
  _Rename(BuildContext context, List<FileEntry> entries)
      : super(
    context: context,
    entries: entries,
    icon: Icon(Icons.edit_outlined),
    name: DriveContextAction.rename,
    displayName: 'Rename',
  );

  onTap() {
    showCrupdateEntryDialog(context, fileEntry: entries[0]);
  }
}

class _Move extends DriveContextActionConfig {
  _Move(BuildContext context, List<FileEntry> entries,
      {this.disableMoveAction = false,
        DriveContextAction? name,
        String? displayName,
        Icon? icon,
        EntryPermission? permission})
      : super(
    context: context,
    entries: entries,
    supportsMultipleEntries: true,
    icon: icon ?? const Icon(Icons.drive_file_move_outline),
    name: name ?? DriveContextAction.move,
    displayName: displayName ?? 'Move / Copy',
    permission: permission ?? EntryPermission.update,
  );
  final bool disableMoveAction;

  onTap() {
    context.read<DestinationPickerState>().open(disableMoveAction: disableMoveAction, entries: entries);
  }
}

class _CopyToOwnDrive extends _Move {
  _CopyToOwnDrive(
      BuildContext context,
      List<FileEntry> entries,
      ) : super(
    context,
    entries,
    disableMoveAction: true,
    name: DriveContextAction.copyToOwnDrive,
    displayName: 'Make a Copy',
    icon: const Icon(Icons.copy_outlined),
    permission: EntryPermission.download,
  );
}

class _Delete extends DriveContextActionConfig {
  _Delete(BuildContext context, List<FileEntry> entries)
      : super(
    context: context,
    entries: entries,
    supportsMultipleEntries: true,
    icon: Icon(Icons.delete_outline_outlined),
    name: DriveContextAction.delete,
    displayName: 'Delete',
    permission: EntryPermission.delete,
  );

  onTap() async {
    try {
      await context.read<DriveState>().deleteEntries(entries.map((e) => e.id).toList());
      context.read<DriveState>().deselectAll();
    } on BackendError catch(e) {
      showSnackBar(trans(e.message), context);
    }
  }
}

class _Unshare extends DriveContextActionConfig {
  _Unshare(BuildContext context, List<FileEntry> entries)
      : super(
    context: context,
    entries: entries,
    supportsMultipleEntries: true,
    icon: Icon(Icons.delete_outline_outlined),
    name: DriveContextAction.delete,
    displayName: 'Remove',
    permission: EntryPermission.delete,
  );

  onTap() async {
    try {
      final state = context.read<DriveState>();
      await state.unshare(entries.first.id, context.read<AuthState>().currentUser!.id);
      showSnackBar(trans('Removed :count items.', replacements: {'count': entries.length.toString()}), context);
    } on BackendError catch (e) {
      showSnackBar(trans(e.message), context);
    }
  }
}

class _Restore extends DriveContextActionConfig {
  _Restore(BuildContext context, List<FileEntry> entries)
      : super(
    context: context,
    entries: entries,
    supportsMultipleEntries: true,
    icon: Icon(Icons.restore_outlined),
    name: DriveContextAction.restore,
    displayName: 'Restore',
    permission: EntryPermission.update,
  );

  onTap() async {
    try {
      await context.read<DriveState>().restoreEntries(entries.map((e) => e.id).toList());
    } on BackendError catch (e) {
      showSnackBar(trans(e.message), context);
    }
  }
}

class _DeleteForever extends DriveContextActionConfig {
  _DeleteForever(BuildContext context, List<FileEntry> entries)
      : super(
    context: context,
    entries: entries,
    supportsMultipleEntries: true,
    icon: Icon(Icons.delete_forever_outlined),
    name: DriveContextAction.deleteForever,
    displayName: 'Delete Forever',
    permission: EntryPermission.delete,
  );

  onTap() async {
    try {
      await context.read<DriveState>().deleteEntries(entries.map((e) => e.id).toList(), deleteForever: true);
      context.read<DriveState>().deselectAll();
    } on BackendError catch(e) {
      showSnackBar(trans(e.message), context);
    }
  }
}

class _ToggleOfflined extends DriveContextActionConfig {
  _ToggleOfflined(BuildContext context, List<FileEntry> entries) : super(
    context: context,
    entries: entries,
    supportsMultipleEntries: true,
    name: DriveContextAction.toggleOfflined,
    permission: EntryPermission.download,
  ) {
    final allOfflined = entries.every((e) => context.read<OfflinedEntries>().offlinedEntryIds.contains(e.id));
    this.displayName = allOfflined ? 'Available offline' : 'Make available offline';
    this.icon = allOfflined ? Icon(Icons.offline_pin_rounded, color: Colors.green) : Icon(Icons.offline_pin_outlined);
  }

  onTap() {
    final offlinedEntries = context.read<OfflinedEntries>();
    if (entries.every((e) => offlinedEntries.offlinedEntryIds.contains(e.id))) {
      offlinedEntries.unoffline(entries);
      if (driveState.activePage is OfflinedPage) {
        driveState.removeEntries(entries.map((e) => e.id).toList(), notify: true);
      }
      showSnackBar(trans('Files will no longer be available offline'), context);
    } else {
      if (offlinedEntries.offline(entries, context: context) != null) {
        showSnackBar(trans('Making files available offline'), context);
      }
    }
  }
}
