import 'package:flutter/material.dart';

import 'package:fitness_flutter/api/wger_api_client.dart';
import 'package:fitness_flutter/l10n/app_strings.dart';
import 'package:fitness_flutter/services/device_sync_service.dart';
import 'package:fitness_flutter/theme/app_theme.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  DevicesPageState createState() => DevicesPageState();
}

class DevicesPageState extends State<DevicesPage> {
  bool _isLoading = true;
  bool _isSyncing = false;
  Map<String, dynamic> _syncStatus = {};
  List<dynamic> _categories = [];

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _leanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _fatController.dispose();
    _waterController.dispose();
    _leanController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final deviceSync = DeviceSyncService.instance;
      final status = await deviceSync.getSyncStatus();
      final api = WgerApiClient.instance;
      final categories = await api.getMeasurementCategories();
      
      if (mounted) {
        setState(() {
          _syncStatus = status;
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _syncNow() async {
    setState(() => _isSyncing = true);
    try {
      await DeviceSyncService.instance.manualSync();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.t(context, 'syncComplete'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.t(context, 'syncFailed'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _addManualEntry() async {
    final api = WgerApiClient.instance;
    final now = DateTime.now();
    bool success = true;

    if (_weightController.text.isNotEmpty) {
      final weight = double.tryParse(_weightController.text);
      if (weight != null) {
        final result = await api.createWeightEntry(weight, now);
        if (result == null) success = false;
      }
    }
    if (_fatController.text.isNotEmpty) {
      final fat = double.tryParse(_fatController.text);
      if (fat != null) {
        final result = await api.createMeasurement(
          categoryName: 'Body Fat Percentage',
          value: fat,
          unit: '%',
          date: DateTime.now(),
        );
        if (result == null) success = false;
      }
    }
    if (_waterController.text.isNotEmpty) {
      final water = double.tryParse(_waterController.text);
      if (water != null) {
        final result = await api.createMeasurement(
          categoryName: 'Body Water Mass',
          value: water,
          unit: 'kg',
          date: DateTime.now(),
        );
        if (result == null) success = false;
      }
    }
    if (_leanController.text.isNotEmpty) {
      final lean = double.tryParse(_leanController.text);
      if (lean != null) {
        final result = await api.createMeasurement(
          categoryName: 'Lean Body Mass',
          value: lean,
          unit: 'kg',
          date: DateTime.now(),
        );
        if (result == null) success = false;
      }
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.t(context, 'entrySaved'))),
        );
        _weightController.clear();
        _fatController.clear();
        _waterController.clear();
        _leanController.clear();
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.t(context, 'error'))),
        );
      }
    }
  }

  Widget _buildSourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isConnected,
    required VoidCallback onTap,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Card(
      color: AppTheme.card(context),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isConnected
                  ? [AppTheme.primary(context), AppTheme.secondary(context)]
                  : [onSurface.withValues(alpha: 0.2), onSurface.withValues(alpha: 0.1)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isConnected ? Colors.white : onSurface.withValues(alpha: 0.5), size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isConnected ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildManualEntryCard() {
    return Card(
      color: AppTheme.card(context),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.t(context, 'manualEntry'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _weightController,
              label: '${AppStrings.t(context, 'weight')} (kg)',
              icon: Icons.monitor_weight,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _fatController,
              label: '${AppStrings.t(context, 'bodyFat')} (%)',
              icon: Icons.percent,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _waterController,
              label: '${AppStrings.t(context, 'bodyWater')} (kg)',
              icon: Icons.water_drop,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _leanController,
              label: '${AppStrings.t(context, 'leanMass')} (kg)',
              icon: Icons.fitness_center,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addManualEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppStrings.t(context, 'save')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: onSurface.withValues(alpha: 0.5)),
        filled: true,
        fillColor: AppTheme.textField(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.t(context, 'devices'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.t(context, 'devices')),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : _syncNow,
            tooltip: AppStrings.t(context, 'syncNow'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sync status
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.secondary(context), AppTheme.primary(context)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sync, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.t(context, 'deviceSync'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _syncStatus['lastSync'] != null && _syncStatus['lastSync'] != 0
                        ? '${AppStrings.t(context, 'lastSync')}: ${DateTime.fromMillisecondsSinceEpoch(_syncStatus['lastSync'] as int).toLocal().toString().substring(0, 16)}'
                        : AppStrings.t(context, 'neverSynced'),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Connected sources
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                AppStrings.t(context, 'connectedSources'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildSourceCard(
              icon: Icons.watch,
              title: AppStrings.t(context, 'appleHealth'),
              subtitle: 'HealthKit',
              isConnected: true, // TODO: check actual connection
              onTap: () => _showSourceDetail('Apple Health'),
            ),
            _buildSourceCard(
              icon: Icons.health_and_safety,
              title: AppStrings.t(context, 'googleHealthConnect'),
              subtitle: 'Health Connect',
              isConnected: true, // TODO: check actual connection
              onTap: () => _showSourceDetail('Google Health Connect'),
            ),
            _buildSourceCard(
              icon: Icons.scale,
              title: AppStrings.t(context, 'smartScale'),
              subtitle: 'Withings, Xiaomi, Renpho...',
              isConnected: false, // BLE not implemented yet
              onTap: () => _showSourceDetail('Smart Scale'),
            ),
            _buildSourceCard(
              icon: Icons.watch_outlined,
              title: AppStrings.t(context, 'wearable'),
              subtitle: 'Fitbit, Garmin, Polar...',
              isConnected: false, // Cloud APIs not implemented yet
              onTap: () => _showSourceDetail('Wearable'),
            ),

            // Manual entry
            _buildManualEntryCard(),

            // Measurement categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.t(context, 'measurementCategories'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/measurements'),
                    icon: const Icon(Icons.history, size: 18),
                    label: Text(AppStrings.t(context, 'viewHistory')),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary(context),
                    ),
                  ),
                ],
              ),
            ),
            if (_categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  AppStrings.t(context, 'noData'),
                  style: TextStyle(color: onSurface.withValues(alpha: 0.5)),
                ),
              )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index] as Map<String, dynamic>;
                    return Card(
                      color: AppTheme.card(context),
                      child: ListTile(
                        leading: Icon(Icons.straighten, color: AppTheme.primary(context)),
                        title: Text(cat['name'] as String? ?? ''),
                        subtitle: Text('Unit: ${cat['unit'] as String? ?? ''}'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showSourceDetail(String source) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(source, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Connect your $source to sync health data automatically.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.t(context, 'done')),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}