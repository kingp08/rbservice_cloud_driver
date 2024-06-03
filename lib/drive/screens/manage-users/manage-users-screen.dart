import 'package:bedrive/drive/dialogs/show-snackbar.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/drive/screens/manage-users/email-chips-input.dart';
import 'package:bedrive/drive/screens/manage-users/manage-entry-users-state.dart';
import 'package:bedrive/drive/screens/manage-users/user-list/entry-user-list.dart';
import 'package:bedrive/drive/screens/manage-users/user-list/get-primary-permission.dart';
import 'package:bedrive/drive/state/file-entry/entry-permissions.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/utils/text.dart';
import 'package:provider/provider.dart';

final GlobalKey<EmailChipsInputState> emailChipInputKey = GlobalKey();

class ManageUsersArgs {
  ManageUsersArgs(this.fileEntry);
  final FileEntry? fileEntry;
}

class ManageUsersScreen extends StatelessWidget {
  static const ROUTE = 'manageUsers';
  ManageUsersScreen(this.fileEntry, {Key? key}) : super(key: key);

  final FileEntry? fileEntry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text(fileEntry!.name, translate: false),
            SizedBox(height: 2),
            text('Share ${fileEntry!.type == 'folder' ? 'Folder' : 'File'}',
                size: 14),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                text('Invite collaborators',
                    style: Theme.of(context).textTheme.subtitle1),
                InitialPermissionPopupButton(),
              ],
            ),
            SizedBox(height: 5),
            EmailChipsInput(onChanged: (value) {
              context
                  .read<ManageEntryUsersState>()
                  .toggleShareButtonState(value.isNotEmpty);
            }, key: emailChipInputKey),
            SizedBox(height: 30),
            text('Who has access',
                style: Theme.of(context).textTheme.subtitle1),
            EntryUsersList(fileEntry),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Container(
          height: 52,
          child: Stack(
            children: [
              ProgressIndicator(),
              Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  alignment: Alignment.centerRight,
                  child: ShareButton(fileEntry)),
            ],
          ),
        ),
      ),
    );
  }
}

class InitialPermissionPopupButton extends StatelessWidget {
  const InitialPermissionPopupButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final EntryPermissionName selectedPermission = getPrimaryPermission(
        context.select((ManageEntryUsersState s) => s.permissionForNewUsers));
    return PopupMenuButton<EntryPermissionName>(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: text(SharedEntryPermissions.displayNames[selectedPermission],
            color: primaryColor),
      ),
      onSelected: (name) async {
        context
            .read<ManageEntryUsersState>()
            .setPermissionsForNewUsers(SharedEntryPermissions.fromName(name));
      },
      itemBuilder: (BuildContext context) {
        return EntryPermissionName.values.map((p) {
          final color = selectedPermission == p ? primaryColor : null;
          return PopupMenuItem<EntryPermissionName>(
            value: p,
            child: text(SharedEntryPermissions.displayNames[p], color: color),
          );
        }).toList();
      },
    );
  }
}

class ProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((ManageEntryUsersState s) => s.loading);
    return isLoading ? LinearProgressIndicator() : Container(height: 4);
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton(
    this.fileEntry, {
    Key? key,
  }) : super(key: key);

  final FileEntry? fileEntry;

  @override
  Widget build(BuildContext context) {
    final loading =
        context.select((ManageEntryUsersState s) => s.loading != false);
    final enabled = context
        .select((ManageEntryUsersState s) => s.shareButtonEnabled != false);
    return Container(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
        child: text('Share'),
        onPressed: loading || !enabled ? null : () => _share(context),
      ),
    );
  }

  _share(BuildContext context) async {
    final state = context.read<ManageEntryUsersState>();
    final chipInputState = emailChipInputKey.currentState!;

    if (chipInputState.chips.isEmpty) {
      return showSnackBar(
          trans('Enter at least one email address to share with.'), context);
    }

    chipInputState.addChip(chipInputState.controller!.text);
    chipInputState.focusNode!.unfocus();
    try {
      await state.addUser(
          fileEntry!.id, chipInputState.chips.map((c) => c.email).toList());
      chipInputState.clearChips();
      showSnackBar(trans('Person added.'), context);
    } on BackendError catch (e) {
      showSnackBar(trans(e.message), context);
    }
  }
}
