import 'package:tiggym_shared/tiggym_shared.dart';

class WeightModel {
  final double weight;
  final WeightUnitEnum unit;

  WeightModel({
    required this.weight,
    required this.unit,
  });

  WeightModel copyWith({
    double? weight,
    WeightUnitEnum? unit,
  }) {
    return WeightModel(
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
    );
  }
}
