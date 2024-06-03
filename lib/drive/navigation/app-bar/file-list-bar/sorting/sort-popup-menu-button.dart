import 'package:bedrive/drive/navigation/app-bar/file-list-bar/sorting/file-sort-options.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/utils/text.dart';
import 'package:provider/provider.dart';

class SortPopupMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activeSortCol = context.select((DriveState s) => s.activePage!.sortColumn);
    final activeSortDir = context.select((DriveState s) => s.activePage!.sortDirection);
    final disableSort = context.select((DriveState s) => s.activePage!.disableSort);

    if (disableSort) {
      return Container();
    }

    return Container(
      child: PopupMenuButton<dynamic>(
        child: _button(activeSortCol, activeSortDir, context),
        onSelected: (dynamic result) {
          EntrySortColumn col = result is EntrySortColumn ? result : activeSortCol;
          EntrySortDirection dir = result is EntrySortDirection ? result : activeSortDir;
          context.read<DriveState>().changeSort(col, dir);
        },
        itemBuilder: (BuildContext context) {
          final columns = EntrySortColumn.values.map((col) {
            return PopupMenuItem<EntrySortColumn>(
              value: col,
              child: text(col.displayName, color: _itemTextColor(context, activeSortCol == col)),
            );
          }).toList();
          final directions = EntrySortDirection.values.map((dir) {
            return PopupMenuItem<EntrySortDirection>(
              value: dir,
              child: text(dir.displayName, color: _itemTextColor(context, activeSortDir == dir)),
            );
          }).toList();
          return [
            _header('DIRECTION'),
            ...directions,
            PopupMenuDivider(),
            _header('SORT BY'),
            ...columns
          ];
        }
      ),
    );
  }
  
  _button(EntrySortColumn col, EntrySortDirection dir, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          text(col.displayName, size: 14, weight: FontWeight.normal, color: Theme.of(context).iconTheme.color),
          SizedBox(width: 2),
          Icon(dir == EntrySortDirection.desc ? Icons.arrow_downward_outlined : Icons.arrow_upward_outlined, size: 16),
        ],
      ),
    );
  }

  PopupMenuItem _header(String title) {
    return PopupMenuItem<EntrySortDirection>(
      enabled: false,
      child: text(title, weight: FontWeight.bold, size: 12),
    );
  }

  Color? _itemTextColor(BuildContext context, bool active) {
    return active ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyText1!.color;
  }
}