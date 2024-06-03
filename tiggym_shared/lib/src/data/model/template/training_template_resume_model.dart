// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../util/helper/date_time_helper.dart';
import '../tag_model.dart';

class TrainingTemplateResumeModel {
  final int id;
  final String name;
  final List<DateTime> lastSessions;
  final List<TagModel> tags;
  final DateTime? deletedAt;

  TrainingTemplateResumeModel({required this.id, required this.name, required this.lastSessions, required this.tags, this.deletedAt});

  TrainingTemplateResumeModel copyWith({
    int? id,
    String? name,
    List<DateTime>? lastSessions,
    List<TagModel>? tags,
    ValueGetter<DateTime?>? deletedAt,
  }) {
    return TrainingTemplateResumeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastSessions: lastSessions ?? this.lastSessions,
      tags: tags ?? this.tags,
      deletedAt: deletedAt != null ? deletedAt.call() : this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory TrainingTemplateResumeModel.fromMap(Map<String, dynamic> map) {
    return TrainingTemplateResumeModel(
      id: map['id'] as int,
      name: map['name'] as String,
      lastSessions: map['lastSessions'] ?? <DateTime>[],
      tags: map['tags'] ?? <DateTime>[],
      deletedAt: map['deletedAt'] != null ? DateTimeHelper.fromSecondsSinceEpoch(map['deletedAt'] as int) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TrainingTemplateResumeModel.fromJson(String source) => TrainingTemplateResumeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'TrainingTemplateResumeModel(id: $id, name: $name)';

  @override
  bool operator ==(covariant TrainingTemplateResumeModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
