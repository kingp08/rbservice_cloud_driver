import 'package:bedrive/drive/screens/manage-users/user-list/entry-user-list-title.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-entry/file-entry-user.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:provider/provider.dart';

class EntryUsersList extends StatelessWidget {
  const EntryUsersList(
    this.fileEntry, {
    Key? key,
  }) : super(key: key);

  final FileEntry? fileEntry;

  @override
  Widget build(BuildContext context) {
    final List<FileEntryUser> entryUsers = context
        .select(((DriveState s) => s.entryCache.get(fileEntry!.id)!.users!));
    return Expanded(
      child: ListView(
        children: [
          ...entryUsers.map(
              (u) => EntryUserListTile(fileEntry: fileEntry, fileEntryUser: u))
        ],
      ),
    );
  }
}
