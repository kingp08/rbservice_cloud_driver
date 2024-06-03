import 'package:bedrive/drive/screens/file-list/base-file-list-screen.dart';
import 'package:bedrive/drive/state/file-pages.dart';

class SharedScreen extends BaseFileListScreen {
  static const ROUTE = 'shared';
  final FilePage page = SharesPage();
}
