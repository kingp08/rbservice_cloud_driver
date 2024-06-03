import 'package:bedrive/auth/user.dart';
import 'package:bedrive/drive/http/app-http-client.dart';
import 'package:bedrive/drive/screens/manage-users/manage-entry-users-state.dart';
import 'package:bedrive/drive/screens/manage-users/sharee-payload.dart';
import 'package:bedrive/drive/screens/manage-users/user-list/change-user-permission-sheet.dart';
import 'package:bedrive/drive/screens/manage-users/user-list/get-primary-permission.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/auth/auth-state.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/file-entry/entry-permissions.dart';
import 'package:bedrive/drive/state/file-entry/file-entry-user.dart';
import 'package:bedrive/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:bedrive/drive/dialogs/show-snackbar.dart';

class EntryUserListTile extends StatelessWidget {
  const EntryUserListTile({
    Key? key,
    required this.fileEntry,
    required this.fileEntryUser,
  }) : super(key: key);
  final FileEntry? fileEntry;
  final FileEntryUser fileEntryUser;

  @override
  Widget build(BuildContext context) {
    final http = context.watch<AppHttpClient>();
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(http.prefixUrl(fileEntryUser.avatar!)),
      ),
      title: text(fileEntryUser.displayName, translate: false),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(fileEntryUser.email, translate: false),
          SizedBox(height: 4),
          CurrentPermissionText(fileEntry: fileEntry, fileEntryUser: fileEntryUser),
        ],
      ),
      trailing: EntryUserTileTrailingAction(
        fileEntry: fileEntry,
        fileEntryUser: fileEntryUser
      ),
      contentPadding: EdgeInsets.all(0),
      isThreeLine: true,
      onTap: _canChangePermission(fileEntry!, fileEntryUser) ? () => _showPermissionSheet(context) : null,
    );
  }

  _showPermissionSheet(BuildContext context) async {
    if ( ! context.read<ManageEntryUsersState>().loading) {
      final selectedPermission = await showModalBottomSheet<EntryPermissionName>(
        context: context,
        builder: (_) => ChangeUserPermissionSheet(fileEntryUser: fileEntryUser, fileEntry: fileEntry),
      );
      if (selectedPermission != null) {
       try {
         await context.read<ManageEntryUsersState>().changePermissions(
           fileEntry!.id,
           ShareePayload(fileEntryUser.id, SharedEntryPermissions.fromName(selectedPermission))
         );
         showSnackBar(trans('Permission updated.'), context);
       } on BackendError catch(e) {
         showSnackBar(trans(e.message), context);
       }
      }
    }
  }
}

class CurrentPermissionText extends StatelessWidget {
  const CurrentPermissionText({
    Key? key,
    required this.fileEntry,
    required this.fileEntryUser,
  }) : super(key: key);

  final FileEntry? fileEntry;
  final FileEntryUser fileEntryUser;

  @override
  Widget build(BuildContext context) {
    if (fileEntryUser.ownsEntry!) {
      return text('Owner');
    }

    final style = _canChangePermission(fileEntry!, fileEntryUser)
      ? TextStyle(color: Theme.of(context).primaryColor)
      : null;

    final content = context.select((ManageEntryUsersState s) => s.updatingUserId == fileEntryUser.id)
      ? 'Updating...'
      : SharedEntryPermissions.displayNames[getPrimaryPermission(fileEntryUser.entryPermissions!)];

    return text(content, style: style);
  }
}

class EntryUserTileTrailingAction extends StatelessWidget {
  const EntryUserTileTrailingAction({
    Key? key,
    required this.fileEntry,
    required this.fileEntryUser,
  }) : super(key: key);

  final FileEntry? fileEntry;
  final FileEntryUser fileEntryUser;

  @override
  Widget build(BuildContext context) {
    final User? currentUser = context.select((AuthState u) => u.currentUser);
    if (fileEntryUser.ownsEntry! || fileEntryUser.id == currentUser!.id) {
      return Text('');
    }

    return IconButton(
        icon: Icon(Icons.close_outlined),
        tooltip: trans('Remove User'),
        onPressed: () async {
          final confirmed = await confirmEntryUserRemoval(context);
          if (confirmed) {
            try {
              await context.read<ManageEntryUsersState>().removeUser(fileEntry!.id, fileEntryUser.id);
              showSnackBar(trans('Removed user.'), context);
            } on BackendError catch (e) {
              showSnackBar(trans(e.message), context);
            }
          }
        }
    );
  }
}

confirmEntryUserRemoval(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: text('Remove User'),
        content: text('Are you sure you want to remove this user?', singleLine: false),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).textTheme.bodyText2!.color),
            child: text('Cancel'),
            onPressed:  () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: text('Remove'),
            onPressed:  () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
}

_canChangePermission(FileEntry fileEntry, FileEntryUser fileEntryUser) {
  return fileEntry.permissions!.contains(EntryPermission.update) && !fileEntryUser.ownsEntry!;
}