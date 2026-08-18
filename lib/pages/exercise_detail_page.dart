import 'package:fitness_flutter/api/wger_api_client.dart';
import 'package:fitness_flutter/l10n/app_strings.dart';
import 'package:fitness_flutter/models/exercise.dart';
import 'package:fitness_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ExerciseDetailPage extends StatefulWidget {
  const ExerciseDetailPage({super.key, required this.exerciseId});

  final int exerciseId;

  @override
  ExerciseDetailPageState createState() => ExerciseDetailPageState();
}

class ExerciseDetailPageState extends State<ExerciseDetailPage> {
  Exercise? _exercise;
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
    final data = await WgerApiClient.instance.getExerciseDetail(widget.exerciseId);
    if (!mounted) return;
    setState(() {
      _exercise = data != null ? Exercise.fromJson(data) : null;
      _loading = false;
      _error = _exercise == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _exercise?.name.isNotEmpty == true
              ? _exercise!.name
              : AppStrings.t(context, 'exercises'),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error || _exercise == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.t(context, 'error'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
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

    final exercise = _exercise!;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(exercise),
          const SizedBox(height: 25),
          Text(
            exercise.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (exercise.category.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.secondary(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                exercise.category,
                style: TextStyle(
                  color: AppTheme.primary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 20),
          _SectionTitle(title: 'Description'),
          const SizedBox(height: 10),
          Text(
            exercise.description,
            style: TextStyle(fontSize: 15, color: onSurface.withOpacity(0.85)),
          ),
          if (exercise.muscles.isNotEmpty) ...[
            const SizedBox(height: 25),
            _SectionTitle(title: 'Muscles'),
            const SizedBox(height: 10),
            _chipWrap(
              context,
              exercise.muscles,
              Icons.fitness_center,
            ),
          ],
          if (exercise.equipment.isNotEmpty) ...[
            const SizedBox(height: 25),
            _SectionTitle(title: 'Equipment'),
            const SizedBox(height: 10),
            _chipWrap(context, exercise.equipment, Icons.tune),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(Exercise exercise) {
    final initial = exercise.name.isNotEmpty
        ? exercise.name.characters.first.toUpperCase()
        : '?';

    Widget fallback = Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            AppTheme.secondary(context),
            AppTheme.primary(context),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );

    if (exercise.imageUrl.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Image.network(
          exercise.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Widget _chipWrap(BuildContext context, List<String> items, IconData icon) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: AppTheme.primary(context),
              ),
              const SizedBox(width: 6),
              Text(item, style: const TextStyle(fontSize: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }
}
