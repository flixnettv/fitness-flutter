class Exercise {
  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.muscles,
    required this.equipment,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String description;
  final String category;
  final List<String> muscles;
  final List<String> equipment;
  final String imageUrl;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final translations = json['translations'] as List<dynamic>? ?? [];
    final translation = translations.isNotEmpty
        ? Map<String, dynamic>.from(translations.first as Map)
        : <String, dynamic>{};

    String stripHtml(String? html) =>
        (html ?? '').replaceAll(RegExp(r'<[^>]*>'), '').trim();

    final muscles = <String>[];
    for (final item in json['muscles'] as List<dynamic>? ?? []) {
      if (item is Map) {
        final name = item['name'];
        if (name is String && name.isNotEmpty) muscles.add(name);
      }
    }

    final equipment = <String>[];
    for (final item in json['equipment'] as List<dynamic>? ?? []) {
      if (item is Map) {
        final name = item['name'];
        if (name is String && name.isNotEmpty) equipment.add(name);
      }
    }

    final category = json['category'];
    final categoryName = category is Map
        ? (category['name'] as String? ?? '')
        : '';

    String imageUrl = '';
    final images = json['images'] as List<dynamic>? ?? [];
    if (images.isNotEmpty && images.first is Map) {
      final image = (images.first as Map)['image'];
      if (image is String) imageUrl = image;
    }

    return Exercise(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: translation['name'] as String? ?? '',
      description: stripHtml(translation['description'] as String? ?? ''),
      category: categoryName,
      muscles: muscles,
      equipment: equipment,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'muscles': muscles,
        'equipment': equipment,
        'imageUrl': imageUrl,
      };
}
