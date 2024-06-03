// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:tiggym_shared/src/data/enum/training_session_state_enum.dart';

class TrainingSessionStateModel {
  final String syncId;
  final TrainingSessionStateEnum state;
  TrainingSessionStateModel({
    required this.syncId,
    required this.state,
  });

  TrainingSessionStateModel copyWith({
    String? syncId,
    TrainingSessionStateEnum? state,
  }) {
    return TrainingSessionStateModel(
      syncId: syncId ?? this.syncId,
      state: state ?? this.state,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'syncId': syncId,
      'state': state.name,
    };
  }

  factory TrainingSessionStateModel.fromMap(Map<String, dynamic> map) {
    return TrainingSessionStateModel(
      syncId: map['syncId'] as String,
      state: TrainingSessionStateEnum.fromName(map['state']),
    );
  }

  String toJson() => json.encode(toMap());

  factory TrainingSessionStateModel.fromJson(String source) => TrainingSessionStateModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'TrainingSessionStateModel(syncId: $syncId, state: $state)';

  @override
  bool operator ==(covariant TrainingSessionStateModel other) {
    if (identical(this, other)) return true;

    return other.syncId == syncId && other.state == state;
  }

  @override
  int get hashCode => syncId.hashCode ^ state.hashCode;
}
