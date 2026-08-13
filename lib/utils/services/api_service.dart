import 'package:dio/dio.dart';
import 'package:moodie/utils/services/auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio dio;

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://3757-103-19-231-251.ngrok-free.app/api',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthService().getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          if (error.response?.statusCode == 401) {
            AuthService().clearSession();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Auth Endpoints
  Future<Response> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    return await dio.post('/login', data: {
      'email': email,
      'password': password,
      if (deviceName != null) 'device_name': deviceName,
    });
  }

  Future<Response> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  Future<Response> googleLogin({
    required String email,
    required String name,
    String? googleId,
    String? avatarUrl,
  }) async {
    return await dio.post('/google-login', data: {
      'email': email,
      'name': name,
      if (googleId != null) 'google_id': googleId,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });
  }

  Future<Response> logout() async {
    return await dio.post('/logout');
  }

  Future<Response> getUser() async {
    return await dio.get('/user');
  }

  Future<Response> updateProfile({
    String? name,
    String? bio,
    String? avatarUrl,
    String? timezone,
  }) async {
    return await dio.put('/user', data: {
      if (name != null) 'name': name,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (timezone != null) 'timezone': timezone,
    });
  }

  // Daily Drinks
  Future<Response> getDailyDrinks({
    String? from,
    String? to,
    int perPage = 15,
  }) async {
    return await dio.get('/daily-drinks', queryParameters: {
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      'per_page': perPage,
    });
  }

  Future<Response> storeDailyDrink({
    required int drinkAmount,
    String? entryDate,
    String? action,
  }) async {
    return await dio.post('/daily-drinks', data: {
      'drink_amount': drinkAmount,
      if (entryDate != null) 'entry_date': entryDate,
      if (action != null) 'action': action,
    });
  }

  // Target Drink
  Future<Response> getTargetDrink() async {
    return await dio.get('/target-drink');
  }

  Future<Response> updateTargetDrink(int targetAmount) async {
    return await dio.put('/target-drink', data: {
      'target_amount': targetAmount,
    });
  }

  // Moods
  Future<Response> getMoods({
    String? mood,
    String? emotions,
    String? from,
    String? to,
    int perPage = 15,
  }) async {
    return await dio.get('/moods', queryParameters: {
      if (mood != null) 'mood': mood,
      if (emotions != null) 'emotions': emotions,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      'per_page': perPage,
    });
  }

  Future<Response> storeMood({
    required String mood,
    required String emotions,
    String? title,
    String? note,
  }) async {
    return await dio.post('/moods', data: {
      'mood': mood,
      'emotions': emotions,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
    });
  }

  Future<Response> showMood(dynamic id) async {
    return await dio.get('/moods/$id');
  }

  Future<Response> updateMood({
    required dynamic id,
    String? mood,
    String? emotions,
    String? title,
    String? note,
  }) async {
    return await dio.put('/moods/$id', data: {
      if (mood != null) 'mood': mood,
      if (emotions != null) 'emotions': emotions,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
    });
  }

  Future<Response> deleteMood(dynamic id) async {
    return await dio.delete('/moods/$id');
  }

  // Notifications
  Future<Response> getNotifications({
    bool? isRead,
    String? topic,
    int perPage = 15,
  }) async {
    return await dio.get('/notifications', queryParameters: {
      if (isRead != null) 'is_read': isRead,
      if (topic != null) 'topic': topic,
      'per_page': perPage,
    });
  }

  Future<Response> markAllNotificationsAsRead() async {
    return await dio.patch('/notifications/read-all');
  }

  Future<Response> markNotificationAsRead(dynamic id) async {
    return await dio.patch('/notifications/$id/read');
  }

  // Menstrual Logs
  Future<Response> getMenstrualLogs({
    String? flow,
    dynamic moodId,
    bool? isPeriodStart,
    String? from,
    String? to,
    int perPage = 15,
  }) async {
    return await dio.get('/menstrual-logs', queryParameters: {
      if (flow != null) 'flow': flow,
      if (moodId != null) 'mood_id': moodId,
      if (isPeriodStart != null) 'is_period_start': isPeriodStart,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      'per_page': perPage,
    });
  }

  Future<Response> storeMenstrualLog({
    required String date,
    dynamic moodId,
    String? flow,
    List<String>? symptoms,
    String? mood,
    bool? isPeriodStart,
    String? note,
  }) async {
    return await dio.post('/menstrual-logs', data: {
      'date': date,
      if (moodId != null) 'mood_id': moodId,
      if (flow != null) 'flow': flow,
      if (symptoms != null) 'symptoms': symptoms,
      if (mood != null) 'mood': mood,
      if (isPeriodStart != null) 'is_period_start': isPeriodStart,
      if (note != null) 'note': note,
    });
  }

  Future<Response> showMenstrualLog(dynamic id) async {
    return await dio.get('/menstrual-logs/$id');
  }

  Future<Response> updateMenstrualLog({
    required dynamic id,
    String? date,
    dynamic moodId,
    String? flow,
    List<String>? symptoms,
    String? mood,
    bool? isPeriodStart,
    String? note,
  }) async {
    return await dio.put('/menstrual-logs/$id', data: {
      if (date != null) 'date': date,
      if (moodId != null) 'mood_id': moodId,
      if (flow != null) 'flow': flow,
      if (symptoms != null) 'symptoms': symptoms,
      if (mood != null) 'mood': mood,
      if (isPeriodStart != null) 'is_period_start': isPeriodStart,
      if (note != null) 'note': note,
    });
  }

  Future<Response> deleteMenstrualLog(dynamic id) async {
    return await dio.delete('/menstrual-logs/$id');
  }
}
