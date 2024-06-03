// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import '../../../data/model/tag_model.dart';
import '../../../util/extensions/date_time_extensions.dart';
import '../../../util/helper/date_time_helper.dart';

class TrainingSessionResumeModel {
  final int id;
  final String name;
  final DateTime date;
  final Duration duration;
  final String order;
  final List<TagModel> tags;

  TrainingSessionResumeModel({
    required this.id,
    required this.name,
    required this.date,
    required this.duration,
    required this.order,
    required this.tags,
  });

  TrainingSessionResumeModel copyWith({
    int? id,
    String? name,
    DateTime? date,
    Duration? duration,
    String? order,
    List<TagModel>? tags,
  }) {
    return TrainingSessionResumeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      order: order ?? this.order,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'date': date.secondsSinceEpoch,
      'duration': duration.inSeconds,
      // 'order': order,
    };
  }

  factory TrainingSessionResumeModel.fromMap(Map<String, dynamic> map) {
    return TrainingSessionResumeModel(
      id: map['id'] as int,
      name: map['name'] as String,
      order: map['order'] as String,
      date: DateTimeHelper.fromSecondsSinceEpoch(map['date'] as int),
      duration: Duration(seconds: map['duration']),
      tags: map['tags'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TrainingSessionResumeModel.fromJson(String source) => TrainingSessionResumeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TrainingSessionResumeModel(id: $id, name: $name, date: $date, duration: $duration)';
  }

  @override
  bool operator ==(covariant TrainingSessionResumeModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.date == date && other.duration == duration;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ date.hashCode ^ duration.hashCode;
  }
}
