// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'mappable_model.dart';

class HomeModel extends MappableModel {
  final Map<DateTime, List<DateTime>> trainingSessions;

  HomeModel({
    required this.trainingSessions,
  });

  HomeModel copyWith({
    Map<DateTime, List<DateTime>>? trainingSessions,
  }) {
    return HomeModel(
      trainingSessions: trainingSessions ?? this.trainingSessions,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'trainingSessions': trainingSessions,
    };
  }

  factory HomeModel.fromMap(Map<String, dynamic> map) {
    return HomeModel(
        trainingSessions: Map<DateTime, List<DateTime>>.from(
      (map['trainingSessions'] as Map<DateTime, List<DateTime>>),
    ));
  }

  String toJson() => json.encode(toMap());

  factory HomeModel.fromJson(String source) => HomeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'HomeModel(trainingSessions: $trainingSessions)';

  @override
  bool operator ==(covariant HomeModel other) {
    if (identical(this, other)) return true;

    return mapEquals(other.trainingSessions, trainingSessions);
  }

  @override
  int get hashCode => trainingSessions.hashCode;
}
