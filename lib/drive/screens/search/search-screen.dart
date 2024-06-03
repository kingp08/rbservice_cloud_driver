import 'package:bedrive/drive/screens/file-list/file-list-container.dart';
import 'package:bedrive/drive/screens/file-list/file-thumbnail.dart';
import 'package:bedrive/drive/screens/search/file-type-suggestions.dart';
import 'package:bedrive/drive/screens/search/search-app-bar.dart';
import 'package:bedrive/drive/state/drive-state.dart';
import 'package:bedrive/drive/state/file-pages.dart';
import 'package:flutter/material.dart';
import 'package:bedrive/utils/text.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  static const ROUTE = 'search';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController? queryController;
  FocusNode? queryFocusNode;
  late DriveState driveState;

  @override
  void initState() {
    queryController = TextEditingController();
    queryFocusNode = FocusNode();
    driveState = context.read<DriveState>();
    driveState.openPage(SearchPage());
    super.initState();
  }

  @override
  dispose() {
    queryController!.dispose();
    queryFocusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchAppBar(context, controller: queryController, focusNode: queryFocusNode),
      body: Builder(
        builder: (context) {
          final shouldShowSuggestions = context.select((DriveState s) {
            final params = s.activePage!.staticQueryParams!;
            return params['query'] == null && params['type'] == null && s.activePage!.folder == null;
          });
          if (shouldShowSuggestions) {
            driveState.clearEntries();
            return FileTypeSuggestions();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QueryTypeChip(),
              Expanded(
                child: FileListContainer(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class QueryTypeChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentType = context.select((DriveState s) => s.activePage!.staticQueryParams!['type']);
    if (currentType == null) {
      return Container();
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: InputChip(
        label: text(currentType),
        avatar: CircleAvatar(
          backgroundColor: Theme.of(context).canvasColor,
          child: getFileTypeImage(currentType, size: FileThumbnailSize.tiny)
        ),
        onDeleted: () {
          context.read<DriveState>().setSearchFilter('type', null, reload: false);
        }
      ),
    );
  }
}