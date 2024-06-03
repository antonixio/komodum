// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ConnectedDeviceModel {
  final String deviceId;
  final String deviceName;

  ConnectedDeviceModel({
    required this.deviceId,
    required this.deviceName,
  });

  ConnectedDeviceModel copyWith({
    String? deviceId,
    String? deviceName,
  }) {
    return ConnectedDeviceModel(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'deviceId': deviceId,
      'deviceName': deviceName,
    };
  }

  factory ConnectedDeviceModel.fromMap(Map<String, dynamic> map) {
    return ConnectedDeviceModel(
      deviceId: map['deviceId'] as String,
      deviceName: map['deviceName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConnectedDeviceModel.fromJson(String source) => ConnectedDeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ConnectedDeviceModel(deviceId: $deviceId, deviceName: $deviceName)';

  @override
  bool operator ==(covariant ConnectedDeviceModel other) {
    if (identical(this, other)) return true;

    return other.deviceId == deviceId && other.deviceName == deviceName;
  }

  @override
  int get hashCode => deviceId.hashCode ^ deviceName.hashCode;
}
