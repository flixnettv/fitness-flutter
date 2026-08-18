import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:fitness_flutter/api/wger_api_client.dart';
import 'package:fitness_flutter/l10n/app_strings.dart';
import 'package:fitness_flutter/theme/app_theme.dart';

class MeasurementsPage extends StatefulWidget {
  const MeasurementsPage({super.key});

  @override
  MeasurementsPageState createState() => MeasurementsPageState();
}

class MeasurementsPageState extends State<MeasurementsPage> {
  List<dynamic> _weightEntries = [];
  List<dynamic> _measurements = [];
  bool _isLoading = true;
  String _selectedPeriod = '30d';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = WgerApiClient.instance;
      final weight = await api.getWeightEntries(limit: 100);
      final meas = await api.getMeasurements(limit: 100);
      if (mounted) {
        setState(() {
          _weightEntries = (weight?['results'] as List<dynamic>? ?? [])
            ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
          _measurements = (meas?['results'] as List<dynamic>? ?? [])
            ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<FlSpot> _getWeightSpots() {
    return _weightEntries.asMap().entries.map((e) {
      final i = e.key.toDouble();
      final entry = e.value as Map<String, dynamic>;
      return FlSpot(i, double.tryParse(entry['weight'] as String? ?? '') ?? 0.0);
    }).toList();
  }

  List<FlSpot> _getBodyFatSpots() {
    final fatEntries = _measurements.where((m) {
      final cat = m['category'] as Map?;
      return cat?['name'] == 'Body Fat Percentage';
    }).toList();
    return fatEntries.asMap().entries.map((e) {
      final i = e.key.toDouble();
      final entry = e.value as Map<String, dynamic>;
      return FlSpot(i, double.tryParse(entry['value'] as String? ?? '') ?? 0.0);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.t(context, 'measurements')),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7d', child: Text('7 Days')),
              const PopupMenuItem(value: '30d', child: Text('30 Days')),
              const PopupMenuItem(value: '90d', child: Text('90 Days')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weight Chart
                    _buildSectionTitle('Weight'),
                    const SizedBox(height: 12),
                    if (_weightEntries.isNotEmpty)
                      _buildWeightChart()
                    else
                      _buildEmptyState('No weight data yet'),
                    const SizedBox(height: 24),

                    // Body Fat Chart
                    _buildSectionTitle('Body Fat %'),
                    const SizedBox(height: 12),
                    _buildBodyFatChart(),
                    const SizedBox(height: 24),
                    const SizedBox(height: 24),

                    // Water & Lean Mass
                    _buildSectionTitle('Body Water & Lean Mass'),
                    const SizedBox(height: 12),
                    _buildWaterLeanCharts(),
                    const SizedBox(height: 24),

                    // Latest entries
                    _buildSectionTitle('Latest Entries'),
                    const SizedBox(height: 12),
                    _buildLatestEntries(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildWeightChart() {
    final spots = _getWeightSpots();
    if (spots.isEmpty) return _buildEmptyState('No weight data');

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _weightEntries.length) {
                    final entry = _weightEntries[value.toInt()];
                    final date = DateTime.tryParse(entry['date'] as String);
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        date != null ? DateFormat('MM/dd').format(date) : '',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text('${value.toInt()}kg', style: const TextStyle(fontSize: 10)),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: spots.length - 1 > 0 ? spots.length - 1 : 1,
          minY: spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2,
          maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primary(context),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: AppTheme.primary(context),
                      strokeWidth: 2,
                      strokeColor: AppTheme.card(context),
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primary(context).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart({
    required List<FlSpot> spots,
    required Color color,
    required String title,
    required String yLabel,
  }) {
    if (spots.isEmpty) return _buildEmptyState('No data');

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                reservedSize: 10,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text('$value$yLabel', style: const TextStyle(fontSize: 10)),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: spots.length - 1 > 0 ? spots.length - 1 : 1,
          minY: spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) - spots.map((s) => s.y).reduce((a, b) => a < b ? a : b)) * 0.1,
          maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) - spots.map((s) => s.y).reduce((a, b) => a < b ? a : b)) * 0.1,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 3,
                      color: color,
                      strokeWidth: 2,
                      strokeColor: AppTheme.card(context),
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterLeanCharts() {
    final waterEntries = _measurements.where((m) {
      final cat = m['category'] as Map?;
      return cat?['name'] == 'Body Water Mass';
    }).toList();
    final leanEntries = _measurements.where((m) {
      final cat = m['category'] as Map?;
      return cat?['name'] == 'Lean Body Mass';
    }).toList();

    return Row(
      children: [
        Expanded(
          child: waterEntries.isNotEmpty
              ? _buildSmallChart(
                  spots: waterEntries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), double.tryParse(e.value['value'] as String? ?? '') ?? 0.0)).toList(),
                  color: Colors.blue,
                  title: 'Water (kg)',
                )
              : _buildEmptyState('No water data', height: 180),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: leanEntries.isNotEmpty
              ? _buildSmallChart(
                  spots: leanEntries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), double.tryParse(e.value['value'] as String? ?? '') ?? 0.0)).toList(),
                  color: Colors.green,
                  title: 'Lean Mass (kg)',
                )
              : _buildEmptyState('No lean mass data', height: 180),
        ),
      ],
    );
  }

  Widget _buildBodyFatChart() {
    final fatSpots = _getBodyFatSpots();
    if (fatSpots.isNotEmpty) {
      return _buildLineChart(
        spots: fatSpots,
        color: Colors.orange,
        title: 'Body Fat %',
        yLabel: '%',
      );
    } else {
      return _buildEmptyState('No body fat data yet');
    }
  }

  Widget _buildSmallChart({
    required List<FlSpot> spots,
    required Color color,
    required String title,
  }) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: spots.length - 1 > 0 ? spots.length - 1 : 1,
                minY: spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 1,
                maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, {double height = 200}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildLatestEntries() {
    final allEntries = <Map<String, dynamic>>[];
    
    for (final w in _weightEntries.take(5)) {
      allEntries.add({
        'type': 'weight',
        'label': 'Weight',
        'value': '${w['weight']} kg',
        'date': w['date'],
      });
    }
    for (final m in _measurements.take(10)) {
      final cat = m['category'] as Map?;
      allEntries.add({
        'type': 'measurement',
        'label': cat?['name'] ?? 'Measurement',
        'value': '${m['value']} ${cat?['unit'] ?? ''}',
        'date': m['date'],
      });
    }
    allEntries.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

    if (allEntries.isEmpty) {
      return _buildEmptyState('No entries yet', height: 100);
    }

    return Column(
      children: allEntries.take(10).map((entry) {
        final date = DateTime.tryParse(entry['date'] as String);
        return Card(
          color: AppTheme.card(context),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(
              entry['type'] == 'weight' ? Icons.monitor_weight : Icons.straighten,
              color: AppTheme.primary(context),
            ),
            title: Text(entry['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(entry['value'] as String),
            trailing: Text(
              date != null ? DateFormat('MMM dd, yyyy').format(date) : '',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
            ),
          ),
        );
      }).toList(),
    );
  }
}