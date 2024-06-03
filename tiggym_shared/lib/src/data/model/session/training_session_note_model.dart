// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:tiggym_shared/src/data/all.dart';

class TrainingSessionNoteModel with MappableModel, DatabaseModel {
  final int id;
  final int trainingSessionId;
  final String note;
  TrainingSessionNoteModel({
    required this.id,
    required this.trainingSessionId,
    required this.note,
  });

  TrainingSessionNoteModel.dummy({required this.note})
      : id = -1,
        trainingSessionId = -1;

  factory TrainingSessionNoteModel.fromMap(Map<String, dynamic> map) {
    return TrainingSessionNoteModel(
      id: map['id'] as int,
      trainingSessionId: map['trainingSessionId'] as int,
      note: map['note'] as String,
    );
  }

  TrainingSessionNoteModel copyWith({
    int? id,
    int? trainingSessionId,
    String? note,
  }) {
    return TrainingSessionNoteModel(
      id: id ?? this.id,
      trainingSessionId: trainingSessionId ?? this.trainingSessionId,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'trainingSessionId': trainingSessionId,
      'note': note,
    };
  }

  @override
  Map<String, dynamic> toDatabase() => toMap();
}
