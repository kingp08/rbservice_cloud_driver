import 'package:bedrive/drive/screens/manage-users/user-list/get-primary-permission.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/file-entry/entry-permissions.dart';
import 'package:bedrive/drive/state/file-entry/file-entry-user.dart';
import 'package:bedrive/utils/text.dart';

class ChangeUserPermissionSheet extends StatelessWidget {
  const ChangeUserPermissionSheet({
    Key? key,
    required this.fileEntry,
    required this.fileEntryUser,
  }) : super(key: key);
  final FileEntry? fileEntry;
  final FileEntryUser fileEntryUser;

  @override
  Widget build(BuildContext context) {
    final children = EntryPermissionName.values.map((permission) {
      final isSelected = getPrimaryPermission(fileEntryUser.entryPermissions!) == permission;
      return ListTile(
        selected: isSelected,
        leading: isSelected ? Icon(Icons.check) : SizedBox(),
        title: text(SharedEntryPermissions.displayNames[permission]),
        onTap: () {
          Navigator.of(context).pop(isSelected ? null : permission);
        },
      );
    }).toList();
    return Container(
      height: 260,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(fileEntryUser.avatar!),
            ),
            title: text(fileEntryUser.displayName, translate: false),
            subtitle: text(fileEntryUser.email, translate: false),
          ),
          Divider(thickness: 1),
          Expanded(
            child: ListView(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}