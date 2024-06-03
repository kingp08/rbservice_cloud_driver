import 'package:bedrive/drive/screens/destination-picker/destination-picker-state.dart';
import 'package:bedrive/drive/screens/destination-picker/entry-move-type.dart';
import 'package:bedrive/drive/screens/file-list/file-list-container.dart';
import 'package:bedrive/drive/dialogs/crupdate-entry-dialog.dart';
import 'package:bedrive/drive/state/file-entry/file-entry.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-pages.dart';
import 'package:bedrive/drive/dialogs/show-snackbar.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DestinationPicker extends StatefulWidget {
  static const ROUTE = 'destinationPicker';
  final FilePage? page;
  DestinationPicker(this.page);

  @override
  _DestinationPickerState createState() => _DestinationPickerState();
}

class _DestinationPickerState extends State<DestinationPicker> {
  List<FileEntry> targetEntries = [];

  @override
  void initState() {
    context.read<DriveState>().openPage(widget.page ?? RootFolderPage());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool disableMoveAction = context.select((DestinationPickerState s) => s.disableMoveAction);
    return Scaffold(
      appBar: AppBar(
        title: DestinationSelectorAppBarTitle(),
        actions: [
          IconButton(icon: Icon(Icons.create_new_folder_outlined), onPressed: () {
            showCrupdateEntryDialog(context, fileType: 'folder').then((fileEntry) {
              context.read<DriveState>().openPage(FolderPage(fileEntry!));
            });
          })
        ],
      ),
      body: FileListContainer(),
      persistentFooterButtons: [
        MoveCopyButton(moveType: EntryMoveType.move),
        !disableMoveAction ? MoveCopyButton(moveType: EntryMoveType.copy) : Text(''),
      ],
    );
  }
}

class MoveCopyButton extends StatelessWidget {
  const MoveCopyButton({
    Key? key,
    required this.moveType,
  }) : super(key: key);

  final EntryMoveType moveType;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: text(moveType == EntryMoveType.move ? 'MOVE HERE' : 'COPY HERE'),
      onPressed: () {
        FileEntry? destination = context.read<DriveState>().activePage!.folder;
        List<FileEntry> targetEntries = context.read<DestinationPickerState>().targetEntries;

        if ( ! DestinationPickerState.canMoveEntriesTo(targetEntries, destination, moveType)) {
          showSnackBar(trans('You cannot move or copy a file to itself or any of its subfolders.'), context);
        } else {
          context.read<DestinationPickerState>().moveEntries(context, moveType, targetEntries, destination);
        }
      }
    );
  }
}

class DestinationSelectorAppBarTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activeFolder = context.select((DriveState s) => s.activePage!.folder);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(activeFolder?.name ?? trans('All Files'), translate: false),
        SizedBox(height: 2),
        text('Choose a destination folder', size: 14),
      ],
    );
  }
}

