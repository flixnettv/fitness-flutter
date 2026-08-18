import 'package:fitness_flutter/api/wger_api_client.dart';

enum DeviceMetricType {
  weight,
  bodyFatPercentage,
  bodyWaterMass,
  leanBodyMass,
  steps,
  heartRate,
  sleepAsleep,
  sleepAwake,
  sleepDeep,
  sleepLight,
  sleepRem,
  sleepInBed,
  workout,
  activeEnergyBurned,
  water,
  bodyMassIndex,
  bodyTemperature,
  bloodGlucose,
  bloodOxygen,
  bloodPressureSystolic,
  bloodPressureDiastolic,
  restingHeartRate,
  walkingHeartRate,
  heartRateVariabilityRMSSD,
  heartRateVariabilitySDNN,
}

class DeviceMetric {
  final DeviceMetricType type;
  final double value;
  final String unit;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String source; // 'apple_health', 'google_health_connect', 'manual', 'withings', etc.
  final String sourceId; // UUID from HealthKit/Health Connect

  DeviceMetric({
    required this.type,
    required this.value,
    required this.unit,
    required this.dateFrom,
    required this.dateTo,
    required this.source,
    required this.sourceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'value': value,
      'unit': unit,
      'date_from': dateFrom.toIso8601String(),
      'date_to': dateTo.toIso8601String(),
      'source': source,
      'source_id': sourceId,
    };
  }

  static DeviceMetric fromJson(Map<String, dynamic> json) {
    return DeviceMetric(
      type: DeviceMetricType.values.firstWhere((e) => e.name == json['type']),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      dateFrom: DateTime.parse(json['date_from'] as String),
      dateTo: DateTime.parse(json['date_to'] as String),
      source: json['source'] as String,
      sourceId: json['source_id'] as String,
    );
  }
}