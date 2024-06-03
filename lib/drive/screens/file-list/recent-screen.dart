import 'package:bedrive/drive/screens/file-list/base-file-list-screen.dart';
import 'package:bedrive/drive/state/file-pages.dart';

class RecentScreen extends BaseFileListScreen {
  static const ROUTE = 'recent';
  final FilePage page = RecentPage();
}
