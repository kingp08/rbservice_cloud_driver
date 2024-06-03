import 'package:bedrive/drive/screens/shareable-link/shareable-link.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:flutter/foundation.dart';

class ShareableLinkState extends ChangeNotifier {
  ShareableLinkState(this.driveState, this.fileEntry) {
    fetchInitialLink().catchError((e) {});
  }

  final DriveState driveState;
  final FileEntry? fileEntry;
  ShareableLink? link;
  bool initialLoadCompleted = false;
  bool loading = true;
  bool? expirationEnabled = false;
  bool? passwordEnabled = false;

  Map<String, dynamic> formPayload = {};

  Future<ShareableLink?> fetchInitialLink() async {
    toggleLoading(true);
    try {
      link = await driveState.api.fetchLink(fileEntry!.id);
    } finally {
      initialLoadCompleted = true;
      toggleLoading(false);
    }

    formPayload['allowEdit'] = link?.allowEdit ?? false;
    formPayload['allowDownload'] = link?.allowDownload ?? true;
    formPayload['password'] = link?.password ?? null;
    formPayload['expiresAt'] = link?.expiresAt ?? null;
    passwordEnabled = link?.password != null;
    expirationEnabled = link?.expiresAt != null;
    notifyListeners();

    return link;
  }

  crupdateLink() async {
    toggleLoading(true);
    try {
      link = await driveState.api.crupdateLink(fileEntry!.id, link, this.formPayload);
      return link;
    } finally {
      toggleLoading(false);
    }
  }

  deleteLink() async {
    toggleLoading(true);
    try {
      await driveState.api.deleteLink(fileEntry!.id);
      link = null;
      expirationEnabled = false;
      passwordEnabled = false;
      formPayload = {};
      return link = null;
    } finally {
      toggleLoading(false);
    }
  }

  setFormValue(String key, dynamic value) {
    this.formPayload[key] = value;
    notifyListeners();
  }

  toggleExpirationEnabled(bool? value) {
    this.expirationEnabled = value;
    // if (link != null) {
    //   link.expiresAt = null;
    // }
    notifyListeners();
  }

  togglePasswordEnabled(bool? value) {
    this.passwordEnabled = value;
    notifyListeners();
  }

  toggleLoading(bool loading) {
    this.loading = loading;
    notifyListeners();
  }
}