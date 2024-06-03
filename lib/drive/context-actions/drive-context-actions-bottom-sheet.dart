import 'package:bedrive/drive/context-actions/context-menu-sizes.dart';
import 'package:bedrive/drive/screens/file-list/file-thumbnail.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriveContextActionsBottomSheet extends StatelessWidget {
  DriveContextActionsBottomSheet(this.entries, this.tiles, this.driveState, {Key? key}): super(key: key);
  final List<FileEntry?> entries;
  final List<ListTile> tiles;
  final DriveState driveState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DriveState>.value(
      value: driveState,
      child: Container(
          height: (tiles.length * CONTEXT_MENU_ITEM_HEIGHT + CONTEXT_MENU_HEADER_HEIGHT).toDouble(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: _Header(entries),
              ),
              Expanded(child: ListView(children: tiles))
            ],
          )
      ),
    );
  }
}

class _Header extends StatelessWidget {
  _Header(this.entries, {Key? key}): super(key: key);
  final List<FileEntry?> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.length == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FileThumbnail(entries[0], size: FileThumbnailSize.small),
          SizedBox(width: 10),
          Expanded(
            child: text(entries[0]!.name, translate: false),
          )
        ],
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(left: 8),
        child: text(':count Items', replacements: {'count': entries.length.toString()}),
      );
    }
  }
}