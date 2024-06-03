import 'package:bedrive/drive/navigation/app-bar/file-list-bar/file-view-mode-button.dart';
import 'package:bedrive/drive/navigation/app-bar/file-list-bar/sorting/sort-popup-menu-button.dart';
import 'package:bedrive/drive/state/file-pages.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:provider/provider.dart';

class FileListBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shouldHide =
    context.select((DriveState s) => s.activePage is SearchPage);
    if (shouldHide) {
      return SliverToBoxAdapter(child: Container());
    }
    return SliverAppBar(
      primary: false,
      automaticallyImplyLeading: false,
      floating: true,
      elevation: 0,
      toolbarHeight: 43,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      iconTheme: Theme.of(context).iconTheme,
      toolbarTextStyle: Theme.of(context).textTheme.bodyText2,
      title: SortPopupMenuButton(),
      centerTitle: false,
      titleSpacing: 4,
      bottom: PreferredSize(
          child: Container(
            color: Theme.of(context).dividerColor,
            height: 1,
          ),
          preferredSize: Size.fromHeight(1)),
      actions: [
        FileViewModeButton(),
      ],
    );
  }
}
