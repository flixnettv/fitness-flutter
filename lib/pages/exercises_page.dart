import 'package:fitness_flutter/api/wger_api_client.dart';
import 'package:fitness_flutter/l10n/app_strings.dart';
import 'package:fitness_flutter/models/exercise.dart';
import 'package:fitness_flutter/pages/exercise_detail_page.dart';
import 'package:fitness_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  ExercisesPageState createState() => ExercisesPageState();
}

class ExercisesPageState extends State<ExercisesPage> {
  List<Exercise> _exercises = [];
  List<Exercise> _filtered = [];
  bool _loading = true;
  bool _error = false;
  final TextEditingController _searchController = TextEditingController();

  bool get _isAr => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    final raw =
        await WgerApiClient.instance.getExercises(lang: _isAr ? 'ar' : 'en');
    final exercises = raw.map((item) {
      if (item is Map<String, dynamic>) return Exercise.fromJson(item);
      if (item is Map) return Exercise.fromJson(Map<String, dynamic>.from(item));
      return Exercise(
        id: 0,
        name: '',
        description: '',
        category: '',
        muscles: const [],
        equipment: const [],
        imageUrl: '',
      );
    }).toList();
    if (!mounted) return;
    setState(() {
      _exercises = exercises;
      _filtered = exercises;
      _loading = false;
    });
  }

  void _onSearchChanged(String value) {
    final query = value.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? _exercises
          : _exercises
              .where((e) => e.name.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t(context, 'exercises'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: AppStrings.t(context, 'search'),
                prefixIcon: Icon(Icons.search, color: onSurface.withValues(alpha: 0.5)),
              ),
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 15),
            _GradientButton(
              label: AppStrings.t(context, 'retry'),
              onTap: _load,
            ),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          AppStrings.t(context, 'noData'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _ExerciseCard(
        exercise: _filtered[index],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ExerciseDetailPage(exerciseId: _filtered[index].id),
            ),
          );
        },
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.onTap});

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final initial =
        exercise.name.isNotEmpty ? exercise.name.characters.first.toUpperCase() : '?';
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary(context).withValues(alpha: 0.15),
          child: Text(
            initial,
            style: TextStyle(
              color: AppTheme.primary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          exercise.category,
          style: TextStyle(color: onSurface.withValues(alpha: 0.6)),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.secondary(context),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
