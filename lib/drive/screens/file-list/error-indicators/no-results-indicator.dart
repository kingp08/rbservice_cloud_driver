import 'package:bedrive/drive/screens/destination-picker/destination-picker-state.dart';
import 'package:bedrive/drive/screens/file-list/error-indicators/base-indicator.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:provider/provider.dart';

class NoResultsIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activeFolder = context.select(((DriveState s) => s.activePage!));
    final destinationPickerMode = context.select((DestinationPickerState s) => s.active);
    return BaseIndicator(
      title: destinationPickerMode ? activeFolder.folder!.name : activeFolder.noResultsTitle,
      message: destinationPickerMode ? 'Use buttons bellow to move or copy files here.' : activeFolder.noResultsMessage,
      assetPath: 'assets/icons/${activeFolder.icon}',
    );
  }
}
