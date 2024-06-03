import 'package:bedrive/drive/navigation/app-bar/main-app-bar/add-new-item-bottom-sheet.dart';
import 'package:bedrive/drive/screens/search/search-screen.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainAppBar extends StatelessWidget {
  const MainAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = context.select((DriveState s) => s.activePage!.name);
    final isFolderPage = context.select((DriveState s) => s.activePage!.folder != null);

    return AppBar(
      elevation: 0,
      title: text(name, translate: !isFolderPage),
      actions: [
        _uploadButton(context),
        _searchButton(context),
      ],
    );
  }
}

_uploadButton(BuildContext context) {
  return IconButton(icon: Icon(Icons.add_outlined), onPressed: () {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext _) => AddNewItemBottomSheet(context.read<DriveState>())
    );
  });
}

_searchButton(BuildContext context) {
  return IconButton(icon: Icon(Icons.search_outlined), onPressed: () {
    Navigator.of(context).pushNamed(SearchScreen.ROUTE);
  });
}


