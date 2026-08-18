import 'package:fitness_flutter/api/wger_api_client.dart';
import 'package:fitness_flutter/l10n/app_strings.dart';
import 'package:fitness_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});

  @override
  RoutinesPageState createState() => RoutinesPageState();
}

class RoutinesPageState extends State<RoutinesPage> {
  List<dynamic> _routines = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    final data = await WgerApiClient.instance.getRoutines();
    if (!mounted) return;
    setState(() {
      _routines = (data?['results'] as List<dynamic>? ?? []);
      _loading = false;
      _error = data == null;
    });
  }

  Future<void> _showCreateDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.t(dialogContext, 'routines')),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: AppStrings.t(dialogContext, 'routines'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppStrings.t(dialogContext, 'cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: Text(AppStrings.t(dialogContext, 'save')),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    final created = await WgerApiClient.instance.createRoutine(name.trim());
    if (!mounted) return;
    if (created) {
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.t(context, 'error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t(context, 'routines'))),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppTheme.secondary(context),
              AppTheme.primary(context),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary(context).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showCreateDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: _buildBody(onSurface),
    );
  }

  Widget _buildBody(Color onSurface) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.t(context, 'error'),
              style: TextStyle(color: onSurface.withOpacity(0.5)),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: _load,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.secondary(context),
                      AppTheme.primary(context),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppStrings.t(context, 'retry'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_routines.isEmpty) {
      return Center(
        child: Text(
          AppStrings.t(context, 'noData'),
          style: TextStyle(color: onSurface.withOpacity(0.5)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _routines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildRoutineCard(_routines[index]),
    );
  }

  Widget _buildRoutineCard(dynamic routine) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final name = routine['name'] as String? ?? '';
    final creationDate = routine['creation_date'] as String? ?? '';
    final days = routine['days'] as List<dynamic>? ?? const [];

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.secondary(context),
                    AppTheme.primary(context),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.fitness_center,
                  color: AppTheme.primary(context),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    creationDate,
                    style: TextStyle(
                      fontSize: 13,
                      color: onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (days.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${days.length} days',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.primary(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
