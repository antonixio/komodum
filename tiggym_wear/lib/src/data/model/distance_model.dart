import 'package:tiggym_shared/tiggym_shared.dart';

class DistanceModel {
  final double distance;
  final DistanceUnitEnum unit;

  DistanceModel({
    required this.distance,
    required this.unit,
  });

  DistanceModel copyWith({
    double? distance,
    DistanceUnitEnum? unit,
  }) {
    return DistanceModel(
      distance: distance ?? this.distance,
      unit: unit ?? this.unit,
    );
  }
}
