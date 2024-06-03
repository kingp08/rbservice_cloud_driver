import 'package:bedrive/drive/screens/file-list/file-thumbnail.dart';
import 'package:bedrive/drive/screens/search/search-file-types.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/utils/text.dart';
import 'package:provider/provider.dart';

class FileTypeSuggestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
          child: text('File types', style: Theme.of(context).textTheme.subtitle1),
        ),
        Expanded(
          child: ListView(
            children: SEARCH_FILE_TYPES.entries.map((e) {
              return ListTile(
                leading: getFileTypeImage(e.key, size: FileThumbnailSize.small),
                title: text(e.value),
                onTap: () {
                  context.read<DriveState>().setSearchFilter('type', e.key);
                  FocusScope.of(context).unfocus();
                },
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}
