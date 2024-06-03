import 'package:bedrive/drive/screens/file-list/base-file-list-screen.dart';
import 'package:bedrive/drive/state/file-pages.dart';

class RootScreen extends BaseFileListScreen {
  static const ROUTE = '/';
  final FilePage page = RootFolderPage();
}
