import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moodie/models/workout_log.dart';
import 'package:moodie/utils/services/auth_service.dart';

class WorkoutApiService {
  final String baseUrl;
  final String Function()
      getToken; // Callback to fetch current Sanctum Bearer token

  WorkoutApiService({
    String? baseUrl,
    String Function()? getToken,
  })  : baseUrl = baseUrl ?? 'https://moodie.aramadani.my.id',
        getToken = getToken ?? (() => AuthService().getToken() ?? '');

  Map<String, String> get _headers {
    final token = getToken();
    return {
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// POST /api/workout-logs
  Future<WorkoutLog> logWorkout({
    required String exerciseType,
    required int repsCount,
    int? durationSeconds,
    int? formAccuracyScore,
    String? entryDate,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/workout-logs'),
      headers: _headers,
      body: jsonEncode({
        'exercise_type': exerciseType,
        'reps_count': repsCount,
        'duration_seconds': durationSeconds,
        'form_accuracy_score': formAccuracyScore,
        'entry_date':
            entryDate ?? DateTime.now().toIso8601String().substring(0, 10),
        'notes': notes,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? decoded;
      return WorkoutLog.fromJson(Map<String, dynamic>.from(data));
    } else {
      throw Exception('Failed to record workout: ${response.body}');
    }
  }

  /// GET /api/workout-logs/summary
  Future<WorkoutSummary> getSummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/workout-logs/summary'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? decoded;
      return WorkoutSummary.fromJson(Map<String, dynamic>.from(data));
    } else {
      throw Exception('Failed to load workout summary');
    }
  }

  /// GET /api/workout-logs
  Future<List<WorkoutLog>> getWorkoutLogs({
    String? exerciseType,
    String? from,
    String? to,
    int page = 1,
  }) async {
    final queryParams = {
      if (exerciseType != null) 'exercise_type': exerciseType,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      'page': page.toString(),
    };

    final uri = Uri.parse('$baseUrl/api/workout-logs')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final list = (decoded['data'] is List)
          ? (decoded['data'] as List)
          : (decoded is List ? decoded : []);
      return list
          .map((item) => WorkoutLog.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else {
      throw Exception('Failed to fetch workout logs');
    }
  }

  /// DELETE /api/workout-logs/{id}
  Future<void> deleteWorkout(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/workout-logs/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete workout');
    }
  }
}
