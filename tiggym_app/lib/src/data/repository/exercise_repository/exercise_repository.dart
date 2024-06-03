import 'package:get_it/get_it.dart';
import 'package:tiggym/src/data/repository/tag_repository/tag_repository.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../stream_crud_repository.dart';

import '../initializable_repository.dart';

class ExerciseRepository extends InitializableRepository<ExerciseModel> with StreamCrudRepository<ExerciseModel, int> {
  final _tagRepository = GetIt.I.get<TagRepository>();
  @override
  String get table => 'exercise';

  @override
  ExerciseModel fromMap(Map<String, dynamic> map) =>
      ExerciseModel.fromMap(Map<String, dynamic>.from(map).addOrUpdate({'tag': _tagRepository.data.value.firstWhereOrNull((element) => element.id == map['tagId'])?.toMap()}));

  @override
  Future<void> delete(int pkValue) async {
    await updateSpecific({'deletedAt': DateTime.now().secondsSinceEpoch}, pkValue);
  }
}
