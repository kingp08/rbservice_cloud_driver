import 'package:bedrive/drive/navigation/app-bar/main-app-bar/main-app-bar.dart';
import 'package:bedrive/drive/navigation/app-bar/selection-mode-app-bar.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:provider/provider.dart';

class AppBarContainer extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = context.select((DriveState s) => s.selectedEntries.isNotEmpty);
    return isSelectionMode ? SelectionModeAppBar() : MainAppBar();
  }
}
