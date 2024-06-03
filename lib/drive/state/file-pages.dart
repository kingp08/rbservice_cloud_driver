import 'package:bedrive/drive/context-actions/drive-context-actions.dart';
import 'package:bedrive/drive/navigation/app-bar/file-list-bar/sorting/file-sort-options.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/offlined-entries/offlined-entries.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

abstract class FilePage {
  String? name;
  final String? uniqueId;
  Map<String, String?>? staticQueryParams;
  EntrySortColumn sortColumn;
  EntrySortDirection sortDirection;
  final bool disableSort;
  final FileEntry? folder;
  final String? icon;
  final String? noResultsMessage;
  final String? noResultsTitle;
  final List<DriveContextAction> contextActions;

  FilePage({
    this.name,
    this.uniqueId,
    this.disableSort = false,
    this.sortColumn = EntrySortColumn.updatedAt,
    this.sortDirection = EntrySortDirection.desc,
    this.staticQueryParams,
    this.folder,
    this.icon,
    this.noResultsMessage,
    this.noResultsTitle,
    this.contextActions = const [
      DriveContextAction.preview,
      DriveContextAction.manageUsers,
      DriveContextAction.shareableLink,
      DriveContextAction.toggleStarred,
      DriveContextAction.toggleOfflined,
      DriveContextAction.rename,
      DriveContextAction.move,
      DriveContextAction.download,
      DriveContextAction.delete,
    ],
  }) {
    if (staticQueryParams == null) {
      staticQueryParams = {};
    }
    if (folder != null) {
      staticQueryParams!['folderId'] = folder!.id.toString();
    }
  }

  Map <String, String?> getQueryParams(int page) {
    return {
      'orderBy': sortColumn.value,
      'page': page.toString(),
      'orderDir': describeEnum(sortDirection),
      'perPage': DriveState.perPage.toString(),
      ...staticQueryParams!,
    };
  }
}

class RecentPage extends FilePage {
  RecentPage() : super(
    name: 'Recent',
    uniqueId: 'recent',
    disableSort: true,
    staticQueryParams: {
      'recentOnly': 'true',
    },

    icon: 'recent-custom.svg',
    noResultsTitle: 'No recent entries.',
    noResultsMessage: 'You have not uploaded any files or folders yet.',
  );
}

class SearchPage extends FilePage {
  SearchPage([FileEntry? folder]) : super(
    name: 'Search results',
    uniqueId: 'search',
    icon: 'search-custom.svg',
    noResultsTitle: 'No matches found.',
    noResultsMessage: 'Try another search with different query or file type.',
  );
}

class SharesPage extends FilePage {
  SharesPage() : super(
    name: 'Shares',
    uniqueId: 'shares',
    staticQueryParams: {
      'sharedOnly': 'true',
    },
    icon: 'share-custom.svg',
    noResultsTitle: 'Shared with me.',
    noResultsMessage: 'Files and folders other people have shared with you.',
    contextActions: [
      DriveContextAction.preview,
      DriveContextAction.manageUsers,
      DriveContextAction.shareableLink,
      DriveContextAction.rename,
      DriveContextAction.copyToOwnDrive,
      DriveContextAction.download,
      DriveContextAction.unshare,
    ],
  );
}

class TrashPage extends FilePage {
  TrashPage() : super(
    name: 'Trash',
    uniqueId: 'trash',
    staticQueryParams: {
      'deletedOnly': 'true',
    },
    icon: 'trash-custom.svg',
    noResultsTitle: 'Trash is empty.',
    noResultsMessage: 'There are no files or folders in your trash currently.',
    contextActions: [
      DriveContextAction.restore,
      DriveContextAction.deleteForever,
    ]
  );
}

class StarredPage extends FilePage {
  StarredPage() : super(
    name: 'Starred',
    uniqueId: 'starred',
    staticQueryParams: {
      'starredOnly': 'true',
    },
    icon: 'add-star-custom.svg',
    noResultsTitle: 'Nothing is starred.',
    noResultsMessage: 'Add stars to files and folders that you want to easily find later.',
  );
}

class OfflinedPage extends FilePage {
  OfflinedPage(this.offlinedEntries) : super(
    name: 'Offline',
    uniqueId: 'offlined',
    icon: 'add-star-custom.svg',
    noResultsTitle: 'You have no offlined files or folders',
    noResultsMessage: 'Save a file or folder for viewing offline from its menu.',
  );
  final OfflinedEntries offlinedEntries;

  getQueryParams(int page) {
    final params = super.getQueryParams(page);
    final perPage = int.parse(params['perPage']!);
    final from = (page - 1) * perPage;
    final to = min(offlinedEntries.offlinedEntryIds.length, from + perPage);
    final entryIds = offlinedEntries.offlinedEntryIds.getRange(from, to);
    // if there are not offlined entries, there's no need to call backend
    if (entryIds.isEmpty) {
      params['skipLoadFromBackend'] = 'true';
    } else {
      params['entryIds'] = offlinedEntries.offlinedEntryIds.getRange(from, to).join(',');
    }
    return params;
  }
}

class RootFolderPage extends FilePage {
  RootFolderPage() : super(
    name: 'Files',
    uniqueId: 'root',
    icon: 'folder-file-custom.svg',
    noResultsTitle: 'This folder is empty.',
    noResultsMessage: 'Tap + to add files here.',
  );
}

class FolderPage extends FilePage {
  FolderPage(FileEntry folder) : super(
    name: folder.name,
    uniqueId: folder.hash,
    folder: folder,
    icon: 'folder-file-custom.svg',
    noResultsTitle: 'This folder is empty.',
    noResultsMessage: 'Tap + to add files here.',
  );
}