import 'package:bedrive/drive/screens/destination-picker/destination-picker-state.dart';
import 'package:bedrive/drive/screens/file-list/file-thumbnail.dart';
import 'package:bedrive/drive/screens/file-list/shared/file-view-tile-actions.dart';
import 'package:bedrive/drive/screens/file-list/shared/file-view-tile-name.dart';
import 'package:bedrive/drive/screens/file-list/shared/file-view-tile-trailing-action.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/offlined-entries/offlined-entries.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileGrid extends StatelessWidget {
  const FileGrid(this.entries, {Key? key}) : super(key: key);
  final List<int?> entries;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int axisCount = 2;

    if (width > 1000) {
      axisCount = 4;
    } else if (width > 600) {
      axisCount = 3;
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: axisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      delegate: SliverChildBuilderDelegate(
            (_, index) {
          final state = context.read<DriveState>();
          final fileEntry = state.entryCache.get(state.entries[index]);
          return FileGridItem(fileEntry);
        },
        childCount: entries.length,
      ),
    );
  }
}

class FileGridItem extends StatelessWidget with FileViewTileActions {
  const FileGridItem(this.fileEntry, {Key? key}) : super(key: key);
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

    return InkResponse(
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        onLongPress: () => onLongPress(context, fileEntry),
        onTap: () => onTap(context, fileEntry),
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1,
          child: Stack(
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).selectedRowColor
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.circular(4),
                          child: FileThumbnail(fileEntry,
                              size: FileThumbnailSize.big),
                        ),
                      ),
                      FileGridItemFooter(fileEntry, isSelected: isSelected)
                    ],
                  )),
              Align(
                alignment: Alignment(-0.92, -0.92),
                child: FileGridItemFloatingInfo(fileEntry: fileEntry),
              )
            ],
          ),
        ));
  }
}

class FileGridItemFooter extends StatelessWidget {
  const FileGridItemFooter(
      this.fileEntry, {
        Key? key,
        this.isSelected,
      }) : super(key: key);

  final FileEntry? fileEntry;
  final bool? isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
        height: 48,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: FileViewTileName(fileEntry),
            ),
            FileViewTitleTrailingAction(
              fileEntry!.id,
              isSelected: isSelected,
            )
          ],
        ),
      ),
    );
  }
}

class FileGridItemFloatingInfo extends StatelessWidget {
  const FileGridItemFloatingInfo({
    Key? key,
    required this.fileEntry,
  }) : super(key: key);

  final FileEntry? fileEntry;

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

    children.add(SizedBox(width: spacerWidth));
    if (isShared) {
      children.add(Icon(Icons.people_alt_sharp, size: 13, color: Colors.white));
      children.add(SizedBox(width: spacerWidth));
    }
    if (isStarred) {
      children.add(Icon(Icons.star_sharp, size: 13, color: Colors.white));
      children.add(SizedBox(width: spacerWidth));
    }
    if (isOfflined) {
      children.add(Icon(Icons.offline_pin, size: 12, color: Colors.white));
    }
    children.add(SizedBox(width: spacerWidth));

    if (children.length == 2) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Color.fromRGBO(0, 0, 0, 0.35),
      ),
      child: Row(
        children: children,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}
