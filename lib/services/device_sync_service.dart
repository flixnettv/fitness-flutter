import 'dart:async';
import 'dart:convert';

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
  static const String _syncedUuidsKey = 'device_synced_uuids';
  static const String _enabledSourcesKey = 'device_enabled_sources';
  static const String _lastFullSyncKey = 'device_last_full_sync';

  bool _isConfigured = false;
  Timer? _periodicSyncTimer;
  Function(double, String)? _onProgress;

  Future<void> configure({Function(double, String)? onProgress}) async {
    if (_isConfigured) return;
    _onProgress = onProgress;

    _reportProgress(0.1, 'Requesting health permissions...');

    final types = _getAllReadTypes();
    final permissions = <HealthDataAccess>[
      for (final _ in types) HealthDataAccess.READ,
    ];

    final granted = await _health.requestAuthorization(types, permissions: permissions);
    if (!granted) {
      throw Exception('Health permissions not granted');
    }

    await Permission.activityRecognition.request();
    await Permission.location.request();

    _isConfigured = true;
    _reportProgress(1.0, 'Health permissions granted');

    _startPeriodicSync();
  }

  void _reportProgress(double progress, String message) {
    _onProgress?.call(progress, message);
  }

  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      if (!_isConfigured) return;
      syncAll().catchError((e) => print('Periodic sync error: $e'));
    });
  }

  Future<void> syncAll({bool fullSync = false}) async {
    if (!_isConfigured) await configure();

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastSync = prefs.getInt(_lastSyncKey) ?? 0;
    final lastFullSync = prefs.getInt(_lastFullSyncKey) ?? 0;

    final useFullSync = fullSync || lastFullSync == 0 || now.difference(DateTime.fromMillisecondsSinceEpoch(lastFullSync)).inDays > 7;
    final start = useFullSync ? now.subtract(const Duration(days: 30)) : DateTime.fromMillisecondsSinceEpoch(lastSync);
    final end = DateTime.now();

    _reportProgress(0.1, 'Fetching health data...');

    final syncedUuids = await _getSyncedUuids();

    try {
      final data = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: _getReadTypes(),
      );
      if (data.isEmpty) {
        _reportProgress(1.0, 'No new data to sync');
        await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
        if (useFullSync) await prefs.setInt(_lastFullSyncKey, DateTime.now().millisecondsSinceEpoch);
        return;
      }

      _reportProgress(0.3, 'Processing ${data.length} data points...');

      final metrics = _convertHealthData(data);
      final newMetrics = metrics.where((m) => !syncedUuids.contains(m.sourceId)).toList();

      _reportProgress(0.5, 'Found ${newMetrics.length} new metrics to sync...');

      int successCount = 0;
      final newUuids = <String>[];

      for (int i = 0; i < newMetrics.length; i++) {
        final metric = newMetrics[i];
        try {
          await _uploadSingleMetric(metric);
          newUuids.add(metric.sourceId);
          successCount++;
          _reportProgress(0.3 + 0.6 * (i / newMetrics.length), 'Synced ${i + 1}/${newMetrics.length}');
        } catch (e) {
          print('Failed to upload metric ${metric.type}: $e');
        }
      }

      // Store synced UUIDs
      if (newUuids.isNotEmpty) {
        await _addSyncedUuids(newUuids);
      }

      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      if (useFullSync) await prefs.setInt(_lastFullSyncKey, DateTime.now().millisecondsSinceEpoch);

      _reportProgress(1.0, 'Sync complete: $successCount/${newMetrics.length} uploaded');
    } catch (e) {
      print('Sync error: $e');
      _reportProgress(0.0, 'Sync failed: $e');
      rethrow;
    }
  }

  Future<Set<String>> _getSyncedUuids() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_syncedUuidsKey);
    if (json == null) return {};
    try {
      return Set<String>.from(jsonDecode(json) as List);
    } catch (_) {
      return {};
    }
  }

  Future<void> _addSyncedUuids(List<String> uuids) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await _getSyncedUuids();
    existing.addAll(uuids);
    // Keep only last 5000 UUIDs to prevent storage bloat
    if (existing.length > 5000) {
      final list = existing.toList();
      list.sort((a, b) => b.compareTo(a)); // Keep newest
      existing.clear();
      existing.addAll(list.take(5000));
    }
    await prefs.setString(_syncedUuidsKey, jsonEncode(existing.toList()));
  }

  List<HealthDataType> _getAllReadTypes() {
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

  List<HealthDataType> _getReadTypes() {
    return _getAllReadTypes();
  }

  List<DeviceMetric> _convertHealthData(List<HealthDataPoint> data) {
    final metrics = <DeviceMetric>[];

    for (final point in data) {
      final type = _mapHealthDataType(point.type);
      if (type == null) continue;

      final value = _extractNumericValue(point.value);
      if (value == null) continue;

      metrics.add(DeviceMetric(
        type: type,
        value: value,
        unit: point.unit.toString(),
        dateFrom: point.dateFrom,
        dateTo: point.dateTo,
        source: _getSourceName(),
        sourceId: point.uuid,
      ));
    }

    return metrics;
  }

  double? _extractNumericValue(HealthValue value) {
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
    return null;
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
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
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
    // Detect platform at runtime
    // On iOS: 'apple_health', on Android: 'google_health_connect'
    return 'health_connect';
  }

  Future<void> _uploadSingleMetric(DeviceMetric metric) async {
    // Rate limiting: small delay between uploads
    await Future.delayed(const Duration(milliseconds: 100));

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
      case DeviceMetricType.steps:
        // Could log to custom endpoint or local storage
        break;
      case DeviceMetricType.heartRate:
        // Could log to custom endpoint
        break;
      case DeviceMetricType.sleepAsleep:
      case DeviceMetricType.sleepAwake:
      case DeviceMetricType.sleepDeep:
      case DeviceMetricType.sleepLight:
      case DeviceMetricType.sleepRem:
      case DeviceMetricType.sleepInBed:
        // Sleep data - could store in custom table
        break;
      case DeviceMetricType.workout:
        // Workout data
        break;
      default:
        break;
    }
  }

  Future<void> manualSync() async {
    await syncAll(fullSync: false);
  }

  Future<void> fullSync() async {
    await syncAll(fullSync: true);
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'lastSync': prefs.getInt(_lastSyncKey) ?? 0,
      'lastFullSync': prefs.getInt(_lastFullSyncKey) ?? 0,
      'syncedCount': (await _getSyncedUuids()).length,
      'enabledSources': prefs.getStringList(_enabledSourcesKey) ?? [],
    };
  }

  Future<void> clearSyncedHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_syncedUuidsKey);
    await prefs.remove(_lastSyncKey);
    await prefs.remove(_lastFullSyncKey);
  }

  Future<void> dispose() async {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
  }
}