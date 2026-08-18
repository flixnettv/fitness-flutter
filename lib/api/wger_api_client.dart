import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WgerApiClient {
  WgerApiClient._internal()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://Fitness.hftv.qzz.io',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final refreshed = await _refresh();
          if (refreshed) {
            final opts = e.requestOptions;
            final token = await _getAccessToken();
            opts.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            } catch (_) {}
          }
        }
        handler.next(e);
      },
    ));
  }

  static final WgerApiClient instance = WgerApiClient._internal();

  final Dio _dio;

  static const String _baseUrl = 'https://Fitness.hftv.qzz.io';
  static const String _accessKey = 'wger_access_token';
  static const String _refreshKey = 'wger_refresh_token';

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  Future<bool> _refresh() async {
    final refreshToken = await _getRefreshToken();
    if (refreshToken == null) return false;
    try {
      final res = await _dio.post(
        '/api/v2/token/refresh/',
        data: {'refresh': refreshToken},
      );
      final access = res.data['access'] as String?;
      if (access == null) return false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessKey, access);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final res = await _dio.post(
        '/allauth/app/v1/auth/login',
        data: {'username': username, 'password': password},
        options: Options(headers: {'Accept': 'application/json'}),
      );
      final meta = res.data['meta'] as Map<String, dynamic>;
      final access = meta['access_token'] as String?;
      final refresh = meta['refresh_token'] as String?;
      if (access == null || refresh == null) return false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessKey, access);
      await prefs.setString(_refreshKey, refresh);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup({
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      final res = await _dio.post(
        '/allauth/app/v1/auth/signup',
        data: {
          'username': username,
          'password': password,
          'email': email,
        },
        options: Options(headers: {'Accept': 'application/json'}),
      );
      final meta = res.data['meta'] as Map<String, dynamic>;
      final access = meta['access_token'] as String?;
      final refresh = meta['refresh_token'] as String?;
      if (access == null || refresh == null) return false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessKey, access);
      await prefs.setString(_refreshKey, refresh);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey) != null;
  }

  Future<List<dynamic>> getExercises({String lang = 'ar'}) async {
    try {
      final res = await _dio.get('/api/v2/exerciseinfo/', queryParameters: {
        'language': _langId(lang),
        'limit': 100,
      });
      final data = res.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final res = await _dio.get('/api/v2/userprofile/');
      return res.data as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getWorkoutSessions() async {
    try {
      final res = await _dio.get('/api/v2/workoutsession/');
      return res.data as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRoutines() async {
    try {
      final res = await _dio.get('/api/v2/routine/');
      return res.data as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMeasurements({int? limit}) async {
    try {
      final res = await _dio.get(
        '/api/v2/measurement/',
        queryParameters: {'limit': limit ?? 100},
      );
      return res.data as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getExerciseDetail(int id) async {
    try {
      final res = await _dio.get(
        '/api/v2/exerciseinfo/$id/',
        queryParameters: {'language': 17},
      );
      return res.data as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getExerciseCategories() async {
    try {
      final res = await _dio.get('/api/v2/exercisecategory/');
      final data = res.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<bool> createRoutine(String name) async {
    try {
      final res = await _dio.post(
        '/api/v2/routine/',
        data: {
          'name': name,
          'start': _todayIso(),
          'end': _endIso(),
        },
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static String _todayIso() => DateTime.now().toIso8601String().substring(0, 10);

  static String _endIso() => DateTime.now()
      .add(const Duration(days: 30))
      .toIso8601String()
      .substring(0, 10);

  Future<Map<String, dynamic>?> getWeightEntries({int? limit}) async {
    try {
      final res = await _dio.get(
        '/api/v2/weightentry/',
        queryParameters: {'limit': limit ?? 30},
      );
      return res.data as Map<String, dynamic>?;
    } catch (e) {
      try {
        final res = await _dio.get(
          '/api/v2/weight/',
          queryParameters: {'limit': limit ?? 30},
        );
        return res.data as Map<String, dynamic>?;
      } catch (e2) {
        return null;
      }
    }
  }

  // Create a weight entry
  Future<Map<String, dynamic>?> createWeightEntry(double weight, DateTime date) async {
    try {
      final res = await _dio.post(
        '/api/v2/weightentry/',
        data: {
          'date': date.toIso8601String().substring(0, 10),
          'weight': weight,
        },
      );
      return res.data as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // Get measurement categories
  Future<List<dynamic>> getMeasurementCategories() async {
    try {
      final res = await _dio.get('/api/v2/measurement-category/');
      final data = res.data as Map<String, dynamic>;
      return data['results'] as List<dynamic>? ?? [];
    } catch (e) {
      return [];
    }
  }

  // Create a measurement category
  Future<Map<String, dynamic>?> createMeasurementCategory({
    required String name,
    required String unit,
    bool isWeight = false,
  }) async {
    try {
      final res = await _dio.post(
        '/api/v2/measurement-category/',
        data: {
          'name': name,
          'unit': unit,
          'is_weight': isWeight,
        },
      );
      return res.data as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // Create a measurement (body fat, water, lean mass, etc.)
  Future<Map<String, dynamic>?> createMeasurement({
    required String categoryName,
    required double value,
    required String unit,
    required DateTime date,
    String notes = '',
  }) async {
    try {
      // First find or create the category
      final categories = await getMeasurementCategories();
      Map<String, dynamic>? category;
      for (final cat in categories) {
        if (cat is Map && cat['name'] == categoryName) {
          category = Map<String, dynamic>.from(cat);
          break;
        }
      }

      if (category == null) {
        // Try to create the category
        final created = await createMeasurementCategory(name: categoryName, unit: unit);
        if (created != null) {
          category = created;
        }
      }

      if (category == null) return null;

      final res = await _dio.post(
        '/api/v2/measurement/',
        data: {
          'category': category['id'],
          'date': date.toIso8601String(),
          'value': value,
          'notes': notes,
        },
      );
      return res.data as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  static String _todayIso() => DateTime.now().toIso8601String().substring(0, 10);

  static String _endIso() => DateTime.now()
      .add(const Duration(days: 30))
      .toIso8601String()
      .substring(0, 10);

  Future<Map<String, dynamic>?> getWeightEntries() async {
    try {
      final res = await _dio.get(
        '/api/v2/weightentry/',
        queryParameters: {'limit': 30},
      );
      return res.data as Map<String, dynamic>?;
    } catch (e) {
      try {
        final res = await _dio.get(
          '/api/v2/weight/',
          queryParameters: {'limit': 30},
        );
        return res.data as Map<String, dynamic>?;
      } catch (e2) {
        return null;
      }
    }
  }

  static String _langId(String lang) => lang == 'ar' ? '17' : '2';

  static String get baseUrl => _baseUrl;
}
