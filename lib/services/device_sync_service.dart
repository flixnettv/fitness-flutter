import 'dart:async';

import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitness_flutter/api/wger_api_client.dart';
import 'package:fitness_flutter/models/device_metric.dart';

class DeviceSyncService {
  DeviceSyncService._internal();
  static final DeviceSyncService instance = DeviceSyncService._internal();

  final Health _health = Health();
  final WgerApiClient _api = WgerApiClient.instance;

  static const String _lastSyncKey = 'device_last_sync';
  static const String _enabledSourcesKey = 'device_enabled_sources';

  bool _isConfigured = false;
  Timer? _periodicSyncTimer;

  Future<void> configure() async {
    if (_isConfigured) return;

    // Request permissions for all supported data types
    final types = <HealthDataType>[
      HealthDataType.WEIGHT,
      HealthDataType.BODY_FAT_PERCENTAGE,
      HealthDataType.BODY_WATER_MASS,
      HealthDataType.LEAN_BODY_MASS,
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_IN_BED,
      HealthDataType.WORKOUT,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.WATER,
      HealthDataType.BODY_MASS_INDEX,
      HealthDataType.BODY_TEMPERATURE,
      HealthDataType.BLOOD_GLUCOSE,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.RESTING_HEART_RATE,
      HealthDataType.WALKING_HEART_RATE,
      HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
      HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    ];

    final permissions = <HealthDataAccess>[
      for (_ in types) HealthDataAccess.READ,
    ];

    final granted = await _health.requestAuthorization(types, permissions: permissions);
    if (!granted) {
      throw Exception('Health permissions not granted');
    }

    // Also request activity recognition for steps
    await Permission.activityRecognition.request();
    await Permission.location.request(); // Required for Health Connect on Android

    _isConfigured = true;

    // Start periodic sync (every 30 minutes when app is running)
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      if (!_isConfigured) return;
      syncAll().catchError((e) => print('Periodic sync error: $e'));
    });
  }

  Future<void> syncAll() async {
    if (!_isConfigured) await configure();

    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt(_lastSyncKey) ?? 0;
    final now = DateTime.now();
    final start = lastSync == 0 ? now.subtract(const Duration(days: 7)) : DateTime.fromMillisecondsSinceEpoch(lastSync);

    final types = _getReadTypes();

    try {
      final data = await _health.getHealthDataFromTypes(start, now, types);
      if (data.isEmpty) return;

      final metrics = _convertHealthData(data);
      await _uploadMetrics(metrics);

      await prefs.setInt(_lastSyncKey, now.millisecondsSinceEpoch);
    } catch (e) {
      print('Sync error: $e');
      rethrow;
    }
  }

  List<HealthDataType> _getReadTypes() {
    return [
      HealthDataType.WEIGHT,
      HealthDataType.BODY_FAT_PERCENTAGE,
      HealthDataType.BODY_WATER_MASS,
      HealthDataType.LEAN_BODY_MASS,
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_IN_BED,
      HealthDataType.WORKOUT,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.WATER,
      HealthDataType.BODY_MASS_INDEX,
      HealthDataType.BODY_TEMPERATURE,
      HealthDataType.BLOOD_GLUCOSE,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.RESTING_HEART_RATE,
      HealthDataType.WALKING_HEART_RATE,
      HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
      HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    ];
  }

  List<DeviceMetric> _convertHealthData(List<HealthDataPoint> data) {
    final metrics = <DeviceMetric>[];

    for (final point in data) {
      final type = _mapHealthDataType(point.type);
      if (type == null) continue;

      final value = point.value is NumericHealthValue
          ? (point.value as NumericHealthValue).numericValue
          : (point.value is AudiogramHealthValue
              ? 0.0
              : (point.value is ElectrocardiogramHealthValue
                  ? 0.0
                  : 0.0));

      metrics.add(DeviceMetric(
        type: type,
        value: value,
        unit: point.unit.stringValue,
        dateFrom: point.dateFrom,
        dateTo: point.dateTo,
        source: _getSourceName(),
        sourceId: point.uuid,
      ));
    }

    return metrics;
  }

  DeviceMetricType? _mapHealthDataType(HealthDataType type) {
    switch (type) {
      case HealthDataType.WEIGHT:
        return DeviceMetricType.weight;
      case HealthDataType.BODY_FAT_PERCENTAGE:
        return DeviceMetricType.bodyFatPercentage;
      case HealthDataType.BODY_WATER_MASS:
        return DeviceMetricType.bodyWaterMass;
      case HealthDataType.LEAN_BODY_MASS:
        return DeviceMetricType.leanBodyMass;
      case HealthDataType.STEPS:
        return DeviceMetricType.steps;
      case HealthDataType.HEART_RATE:
        return DeviceMetricType.heartRate;
      case HealthDataType.SLEEP_ASLEEP:
        return DeviceMetricType.sleepAsleep;
      case HealthDataType.SLEEP_AWAKE:
        return DeviceMetricType.sleepAwake;
      case HealthDataType.SLEEP_DEEP:
        return DeviceMetricType.sleepDeep;
      case HealthDataType.SLEEP_LIGHT:
        return DeviceMetricType.sleepLight;
      case HealthDataType.SLEEP_REM:
        return DeviceMetricType.sleepRem;
      case HealthDataType.SLEEP_IN_BED:
        return DeviceMetricType.sleepInBed;
      case HealthDataType.WORKOUT:
        return DeviceMetricType.workout;
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return DeviceMetricType.activeEnergyBurned;
      case HealthDataType.WATER:
        return DeviceMetricType.water;
      case HealthDataType.BODY_MASS_INDEX:
        return DeviceMetricType.bodyMassIndex;
      case HealthDataType.BODY_TEMPERATURE:
        return DeviceMetricType.bodyTemperature;
      case HealthDataType.BLOOD_GLUCOSE:
        return DeviceMetricType.bloodGlucose;
      case HealthDataType.BLOOD_OXYGEN:
        return DeviceMetricType.bloodOxygen;
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
        return DeviceMetricType.bloodPressureSystolic;
      case HealthDataDataType.BLOOD_PRESSURE_DIASTOLIC:
        return DeviceMetricType.bloodPressureDiastolic;
      case HealthDataType.RESTING_HEART_RATE:
        return DeviceMetricType.restingHeartRate;
      case HealthDataType.WALKING_HEART_RATE:
        return DeviceMetricType.walkingHeartRate;
      case HealthDataType.HEART_RATE_VARIABILITY_RMSSD:
        return DeviceMetricType.heartRateVariabilityRMSSD;
      case HealthDataType.HEART_RATE_VARIABILITY_SDNN:
        return DeviceMetricType.heartRateVariabilitySDNN;
      default:
        return null;
    }
  }

  String _getSourceName() {
    // On iOS this would be 'apple_health', on Android 'google_health_connect'
    // For now, detect platform or use a generic name
    return 'device_sync';
  }

  Future<void> _uploadMetrics(List<DeviceMetric> metrics) async {
    for (final metric in metrics) {
      try {
        await _uploadSingleMetric(metric);
      } catch (e) {
        print('Failed to upload metric ${metric.type}: $e');
      }
    }
  }

  Future<void> _uploadSingleMetric(DeviceMetric metric) async {
    // Check if already synced (by sourceId)
    // For now, we upload all - wger API will handle duplicates via unique constraints
    // In production, check local storage for synced UUIDs

    switch (metric.type) {
      case DeviceMetricType.weight:
        await _api.createWeightEntry(metric.value, metric.dateFrom);
        break;
      case DeviceMetricType.bodyFatPercentage:
        await _api.createMeasurement(
          categoryName: 'Body Fat Percentage',
          value: metric.value,
          unit: '%',
          date: metric.dateFrom,
        );
        break;
      case DeviceMetricType.bodyWaterMass:
        await _api.createMeasurement(
          categoryName: 'Body Water Mass',
          value: metric.value,
          unit: 'kg',
          date: metric.dateFrom,
        );
        break;
      case DeviceMetricType.leanBodyMass:
        await _api.createMeasurement(
          categoryName: 'Lean Body Mass',
          value: metric.value,
          unit: 'kg',
          date: metric.dateFrom,
        );
        break;
      default:
        // Other metrics could be stored in a separate table or logged
        print('Metric ${metric.type} logged: ${metric.value} ${metric.unit}');
    }
  }

  Future<void> manualSync() async {
    await syncAll();
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'lastSync': prefs.getInt(_lastSyncKey) ?? 0,
      'enabledSources': prefs.getStringList(_enabledSourcesKey) ?? [],
    };
  }

  Future<void> dispose() async {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
  }
}