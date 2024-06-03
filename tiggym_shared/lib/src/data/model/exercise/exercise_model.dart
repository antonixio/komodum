// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tiggym_shared/src/data/all.dart';
import '../../../data/enum/exercise_type_enum.dart';
import '../../../data/model/tag_model.dart';
import '../../../util/extensions/date_time_extensions.dart';
import '../../../util/extensions/string_extensions.dart';

import '../../../util/helper/date_time_helper.dart';
import '../mappable_model.dart';

class ExerciseModel with MappableModel, DatabaseModel {
  final int id;
  final String name;
  final String? code;
  final TagModel? tag;
  final ExerciseTypeEnum type;
  final bool fromApp;
  final DateTime? deletedAt;

  String getName(BuildContext context) {
    return (code ?? '').isNotEmpty ? 'exercise$code'.getTranslation(context) : name;
  }

  ExerciseModel({
    required this.id,
    required this.name,
    this.code,
    this.tag,
    required this.type,
    required this.fromApp,
    this.deletedAt,
  });

  static ExerciseModel get dummy => ExerciseModel(
        id: -1,
        type: ExerciseTypeEnum.repsAndWeight,
        code: null,
        tag: null,
        name: '',
        fromApp: false,
      );

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] as int,
      name: map['name'] as String,
      code: map['code'] != null ? map['code'] as String : null,
      tag: map['tag'] != null ? TagModel.fromMap(map['tag']) : null,
      type: ExerciseTypeEnum.fromName(map['type']),
      fromApp: map['fromApp'] == 1,
      deletedAt: map['deletedAt'] != null ? DateTimeHelper.fromSecondsSinceEpoch(map['deletedAt'] as int) : null,
    );
  }
  ExerciseModel copyWith({
    int? id,
    String? name,
    String? code,
    TagModel? tag,
    ExerciseTypeEnum? type,
    bool? fromApp,
    ValueGetter<DateTime?>? deletedAt,
  }) {
    return ExerciseModel(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        tag: tag ?? this.tag,
        type: type ?? this.type,
        fromApp: fromApp ?? this.fromApp,
        deletedAt: deletedAt != null ? deletedAt.call() : this.deletedAt);
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'code': code,
      'tagId': tag?.id,
      'type': type.name,
      'fromApp': fromApp,
      'deletedAt': deletedAt?.secondsSinceEpoch,
      'tag': tag?.toMap(),
    };
  }

  @override
  Map<String, dynamic> toDatabase() => toMap()..remove('tag');
}
