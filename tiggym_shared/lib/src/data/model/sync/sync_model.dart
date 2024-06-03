import 'dart:convert';

import 'package:tiggym_shared/src/data/all.dart';
import 'package:tiggym_shared/src/util/helper/date_time_helper.dart';

class SyncModel<T extends MappableModel> extends MappableModel {
  final String id;
  final String previousId;
  final String deviceId;
  final String deviceName;
  final T data;
  DateTime dateTime;

  SyncModel({
    required this.id,
    required this.previousId,
    required this.deviceId,
    required this.deviceName,
    required this.data,
    DateTime? dateTime,
  }) : dateTime = dateTime ?? DateTime.now();

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'previousId': previousId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'data': jsonEncode(data.toMap()),
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  factory SyncModel.fromMap(
    Map<String, dynamic> map,
    T Function(Map<String, dynamic>) dataMapper,
  ) {
    return SyncModel(
      id: map['id'],
      previousId: map['previousId'],
      deviceId: map['deviceId'],
      deviceName: map['deviceName'],
      data: dataMapper.call(jsonDecode(map['data'])),
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] ?? 0),
    );
  }

  SyncModel<T> copyWith({
    String? id,
    String? previousId,
    String? deviceId,
    String? deviceName,
    T? data,
    DateTime? dateTime,
  }) {
    return SyncModel<T>(
      id: id ?? this.id,
      previousId: previousId ?? this.previousId,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      data: data ?? this.data,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
