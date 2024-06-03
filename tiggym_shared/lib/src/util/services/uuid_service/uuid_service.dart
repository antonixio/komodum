import 'package:uuid/uuid.dart';

class UuidService {
  UuidService._privateConstructor();

  static final UuidService instance = UuidService._privateConstructor();

  String uuid() => const Uuid().v4();
}
