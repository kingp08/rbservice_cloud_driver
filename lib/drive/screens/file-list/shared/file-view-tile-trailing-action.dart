import 'package:bedrive/drive/context-actions/show-drive-context-actions.dart';
import 'package:bedrive/drive/screens/destination-picker/destination-picker-state.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:provider/provider.dart';

class FileViewTitleTrailingAction extends StatelessWidget {
  FileViewTitleTrailingAction(
    this.entryId,
    {Key? key, required this.isSelected}
  );

  final int entryId;
  final bool? isSelected;

  @override
  Widget build(BuildContext context) {
    final inSelectMode = context.select((DriveState s) => s.selectedEntries.isNotEmpty);
    final destinationPickerMode = context.select((DestinationPickerState s) => s.active);
    final fileEntry = context.select((DriveState s) => s.entryCache.get(entryId));

    if (destinationPickerMode || fileEntry == null) {
      return Text('');
    }

    return inSelectMode
      ? Checkbox(value: isSelected, onChanged: (_) {
        context.read<DriveState>().toggleEntry(fileEntry);
      })
      : IconButton(
        icon: const Icon(Icons.more_vert_rounded),
        visualDensity: VisualDensity.compact,
        onPressed: () {
          showDriveContextActions([fileEntry], context: context);
        }
    );
  }
}
