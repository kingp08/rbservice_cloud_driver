import 'package:bedrive/drive/screens/file-list/base-file-list-screen.dart';
import 'package:bedrive/drive/state/file-pages.dart';

class StarredScreen extends BaseFileListScreen {
  static const ROUTE = 'starred';
  final FilePage page = StarredPage();
}
