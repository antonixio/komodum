import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;

class PathService {
  PathService._privateConstructor();

  static final PathService instance = PathService._privateConstructor();

  Future<Directory> getApplicationCacheDirectory2() => path_provider.getApplicationCacheDirectory();
  // Future<Directory> getTemporaryDirectory() => getTemporaryDirectory();
}
