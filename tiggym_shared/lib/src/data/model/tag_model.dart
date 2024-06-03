// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tiggym_shared/src/data/all.dart';
import 'package:tiggym_shared/src/util/extensions/date_time_extensions.dart';
import 'package:tiggym_shared/src/util/extensions/string_extensions.dart';
import 'package:tiggym_shared/src/util/helper/date_time_helper.dart';

import 'mappable_model.dart';

class TagModel with MappableModel, DatabaseModel {
  final bool mainTag;
  final bool fromApp;
  final String name;
  final String? code;
  final int id;
  final int? mainTagId;
  final Color color;
  final DateTime? deletedAt;

  static final tagNone = TagModel(
    color: Colors.grey,
    id: -1,
    mainTag: true,
    name: 'None',
    fromApp: true,
    mainTagId: null,
  );
  static TagModel dummy = TagModel(
    mainTag: true,
    name: '',
    id: -1,
    fromApp: false,
    color: Colors.accents.first.shade100,
  );

  TagModel({
    required this.mainTag,
    this.fromApp = false,
    required this.name,
    this.code,
    required this.id,
    this.mainTagId,
    required this.color,
    this.deletedAt,
  });

  String getName(BuildContext context) {
    return (code ?? '').isNotEmpty ? 'tag$code'.getTranslation(context) : name;
  }

  TagModel copyWith({
    bool? mainTag,
    bool? fromApp,
    String? name,
    int? id,
    Color? color,
    ValueGetter<DateTime?>? deletedAt,
    ValueGetter<int?>? mainTagId,
  }) {
    return TagModel(
      mainTag: mainTag ?? this.mainTag,
      fromApp: fromApp ?? this.fromApp,
      name: name ?? this.name,
      id: id ?? this.id,
      mainTagId: mainTagId != null ? mainTagId.call() : this.mainTagId,
      color: color ?? this.color,
      deletedAt: deletedAt != null ? deletedAt.call() : this.deletedAt,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'mainTag': mainTag ? 1 : 0,
      'fromApp': fromApp ? 1 : 0,
      'name': name,
      'code': code,
      'id': id,
      'mainTagId': mainTagId,
      'color': color.value,
      'deletedAt': deletedAt?.secondsSinceEpoch,
    };
  }

  factory TagModel.fromMap(Map<String, dynamic> map) {
    return TagModel(
      mainTag: map['mainTag'] == 1,
      fromApp: map['fromApp'] == 1,
      name: map['name'] as String,
      code: map['code'] as String?,
      id: map['id'] as int,
      mainTagId: map['mainTagId'] != null ? map['mainTagId'] as int : null,
      color: Color(map['color'] as int),
      deletedAt: map['deletedAt'] != null ? DateTimeHelper.fromSecondsSinceEpoch(map['deletedAt'] as int) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TagModel.fromJson(String source) => TagModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TagModel(mainTag: $mainTag, fromApp: $fromApp, name: $name, id: $id, mainTagId: $mainTagId, color: $color)';
  }

  @override
  bool operator ==(covariant TagModel other) {
    if (identical(this, other)) return true;

    return other.mainTag == mainTag && other.fromApp == fromApp && other.name == name && other.id == id && other.mainTagId == mainTagId && other.color == color;
  }

  @override
  int get hashCode {
    return mainTag.hashCode ^ fromApp.hashCode ^ name.hashCode ^ id.hashCode ^ mainTagId.hashCode ^ color.hashCode;
  }

  @override
  Map<String, dynamic> toDatabase() => toMap();
}
