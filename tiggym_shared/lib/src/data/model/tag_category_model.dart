import 'tag_model.dart';

class TagCategoryModel {
  final TagModel mainTag;
  final List<TagModel> list;

  TagCategoryModel({
    required this.mainTag,
    required this.list,
  });
}
