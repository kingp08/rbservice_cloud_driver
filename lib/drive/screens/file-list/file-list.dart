import 'package:bedrive/drive/screens/destination-picker/destination-picker-state.dart';
import 'package:bedrive/drive/screens/file-list/shared/file-view-tile-actions.dart';
import 'package:bedrive/drive/screens/file-list/shared/file-view-tile-name.dart';
import 'package:bedrive/drive/screens/file-list/shared/file-view-tile-trailing-action.dart';
import 'package:bedrive/drive/state/offlined-entries/offlined-entries.dart';
import 'package:charcode/html_entity.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/drive/screens/file-list/file-thumbnail.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/utils/text.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FileList extends StatelessWidget {
  const FileList(this.entries, {Key? key}) : super(key: key);
  final List<int?> entries;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) {
          final state = context.read<DriveState>();
          final fileEntry = state.entryCache.get(state.entries[index]);
          return FileListItem(fileEntry);
        },
        childCount: entries.length,
      ),
    );
  }
}

class FileListItem extends StatelessWidget with FileViewTileActions {
  const FileListItem(this.fileEntry, {Key? key}) : super(key: key);
  final FileEntry? fileEntry;

  @override
  Widget build(BuildContext context) {
    final isDestinationPicker =
        context.select((DestinationPickerState s) => s.active);
    final isSelected = !isDestinationPicker &&
        context.select(
            (DriveState s) => s.selectedEntries.contains(fileEntry!.id));
    final isDisabled = isDestinationPicker &&
        (fileEntry!.type != 'folder' ||
            !fileEntry!.permissions!.contains(EntryPermission.update));

    return ListTile(
      leading: Container(
        width: 40,
        alignment: Alignment.center,
        child: FileThumbnail(fileEntry, size: FileThumbnailSize.small),
      ),
      title: FileViewTileName(fileEntry),
      subtitle: FileListItemSubtitle(fileEntry: fileEntry),
      trailing: FileViewTitleTrailingAction(
        fileEntry!.id,
        isSelected: isSelected,
      ),
      onLongPress: () => onLongPress(context, fileEntry),
      onTap: () => onTap(context, fileEntry),
      selected: isSelected,
      enabled: !isDisabled,
    );
  }
}

class FileListItemSubtitle extends StatelessWidget {
  FileListItemSubtitle({
    Key? key,
    required this.fileEntry,
  }) : super(key: key);

  final FileEntry? fileEntry;
  final df = DateFormat('MMM dd yyyy');

  @override
  Widget build(BuildContext context) {
    bool isStarred = context
        .select((DriveState s) => s.entryCache.get(fileEntry!.id)!.isStarred());
    bool isShared = context.select(
        (DriveState s) => s.entryCache.get(fileEntry!.id)!.users!.length > 1);
    bool isOfflined = context.select(
        (OfflinedEntries s) => s.offlinedEntryIds.contains(fileEntry!.id));
    double spacerWidth = 2;
    final children = <Widget>[];

    if (isShared) {
      children.add(Icon(Icons.people_alt_sharp, size: 13));
      children.add(SizedBox(width: spacerWidth));
    }
    if (isStarred) {
      children.add(Icon(Icons.star_sharp, size: 13));
      children.add(SizedBox(width: spacerWidth));
    }
    if (isOfflined) {
      children.add(Icon(Icons.offline_pin, size: 12));
      children.add(SizedBox(width: spacerWidth));
    }
    if (isShared || isStarred || isOfflined) {
      children.add(SizedBox(width: 5));
    }

    children.add(text(
      '${df.format(fileEntry!.createdAt)} ${String.fromCharCode($middot)} ${filesize(fileEntry!.fileSize ?? 0)}',
      translate: false,
      size: 13,
    ));

    return Row(children: children);
  }
}
