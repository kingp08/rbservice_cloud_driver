import 'dart:io';
import 'package:bedrive/auth/user.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  late LocalStorageAdapter permanent;
  late LocalStorageAdapter temporary;

  Future<LocalStorage> init() async {
    permanent = LocalStorageAdapter(await (Platform.isIOS ? getLibraryDirectory() : getApplicationSupportDirectory()));
    temporary = LocalStorageAdapter(await getTemporaryDirectory());
    return this;
  }
}

class LocalStorageAdapter {
  LocalStorageAdapter(this.rootDir);
  Directory rootDir;

  scopedToUser(User user) {
    return scopedToSubDir(user.id.toString());
  }

  LocalStorageAdapter scopedToSubDir(String dirName) {
    final scopedRootDir = Directory('${rootDir.path}/$dirName');
    scopedRootDir.createSync();
    return LocalStorageAdapter(scopedRootDir);
  }

  Future<String?> get(String fileName) async {
    final file = File('${rootDir.path}/$fileName');
    if (await file.exists()) {
      return File('${rootDir.path}/$fileName').readAsString();
    }
    return null;
  }

  Future<File> put(String fileName, String contents) async {
    return File('${rootDir.path}/$fileName').writeAsString(contents);
  }

  Future<void> delete(String? fileName) async {
    final file = File('${rootDir.path}/$fileName');
    if (await exists(fileName)) {
      await file.delete();
    }
  }

  Future<bool> exists(String? fileName) async {
    final file = File('${rootDir.path}/$fileName');
    return await file.exists();
  }

  int spaceUsed() {
    int totalSize = 0;
    if (rootDir.existsSync()) {
      rootDir.listSync(recursive: true, followLinks: false)
          .forEach((FileSystemEntity entity) {
        if (entity is File) {
          totalSize += entity.lengthSync();
        }
      });
    }
    return totalSize;
  }

  deleteContents() {
    return rootDir.listSync()
        .forEach((e) => e.deleteSync(recursive: true));
  }
}