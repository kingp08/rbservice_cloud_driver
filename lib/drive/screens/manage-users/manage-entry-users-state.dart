import 'package:bedrive/drive/screens/manage-users/sharee-payload.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-entry/entry-permissions.dart';
import 'package:bedrive/drive/state/file-entry/file-entry-user.dart';
import 'package:flutter/material.dart';

class ManageEntryUsersState extends ChangeNotifier {
  ManageEntryUsersState(this.driveState);

  SharedEntryPermissions permissionForNewUsers = SharedEntryPermissions();
  final DriveState driveState;
  bool loading = false;
  int? updatingUserId;
  bool shareButtonEnabled = false;

  addUser(int entryId, List<String> emails) async {
    toggleLoading(true);
    try {
      final users = await driveState.api.addUsers(entryId, emails, permissionForNewUsers);
      return driveState.updateEntryUsers([entryId], users);
    } finally {
      toggleLoading(false);
    }
  }

  removeUser(int entryId, int? userId) async {
    toggleLoading(true);
    try {
      return await driveState.unshare(entryId, userId);
    } finally {
      toggleLoading(false);
    }
  }

  Future<List<FileEntryUser>> changePermissions(int entryId, ShareePayload sharee) async {
    toggleLoading(true, userId: sharee.id);
    try {
      final users = await driveState.api.changePermissions(entryId, sharee);
      return driveState.updateEntryUsers([entryId], users);
    } finally {
      toggleLoading(false);
    }
  }

  toggleLoading(bool loading, {int? userId}) {
    updatingUserId = userId;
    this.loading = loading;
    notifyListeners();
  }

  toggleShareButtonState(bool enabled) {
    shareButtonEnabled = enabled;
    notifyListeners();
  }

  setPermissionsForNewUsers(SharedEntryPermissions permissions) {
    permissionForNewUsers = permissions;
    notifyListeners();
  }
}