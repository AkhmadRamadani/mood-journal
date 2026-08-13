import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:moodie/utils/services/auth_service.dart';
import 'package:moodie/utils/services/local_db_service.dart';

// ---------------------------------------------------------------------------
// Result type – replaces silent fallbacks
// ---------------------------------------------------------------------------

abstract class NetworkResult<T> {
  const NetworkResult();
}

class NetworkSuccess<T> extends NetworkResult<T> {
  final T data;
  const NetworkSuccess(this.data);
}

class NetworkFailure<T> extends NetworkResult<T> {
  final String message;
  final int? statusCode;
  final Object? error;

  const NetworkFailure({required this.message, this.statusCode, this.error});

  @override
  String toString() =>
      'NetworkFailure(message: $message, statusCode: $statusCode, error: $error)';
}

extension NetworkResultX<T> on NetworkResult<T> {
  bool get isSuccess => this is NetworkSuccess<T>;
  bool get isFailure => this is NetworkFailure<T>;

  T get data => (this as NetworkSuccess<T>).data;

  T dataOr(T fallback) =>
      isSuccess ? (this as NetworkSuccess<T>).data : fallback;

  NetworkFailure<T> get failure => this as NetworkFailure<T>;
}

// ---------------------------------------------------------------------------
// DataSource – controls cache vs network priority
// ---------------------------------------------------------------------------

enum DataSource {
  /// Return local cache only. Never hits the network.
  cacheOnly,

  /// Hit the network only. Never reads from cache.
  networkOnly,

  /// Return cache if available, otherwise fall back to network.
  cacheFirst,

  /// Hit network first, persist result, fall back to cache on failure.
  networkFirst,

  /// Return cache immediately (if available), then fetch network in background
  /// and persist the fresh result. Use [onRefreshed] in [getData] to react to
  /// the fresh data and update your UI.
  staleWhileRevalidate,
}

// ---------------------------------------------------------------------------
// HeaderStrategy
// ---------------------------------------------------------------------------

enum HeaderStrategy {
  /// Standard authenticated headers (default).
  global,

  /// Caller supplies headers directly via [customHeader].
  custom,

  /// No headers at all.
  none,
}

// ---------------------------------------------------------------------------
// TokenRefreshManager – isolates single-flight refresh state
// ---------------------------------------------------------------------------

class TokenRefreshManager {
  TokenRefreshManager._();
  static final TokenRefreshManager instance = TokenRefreshManager._();

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  Future<bool> refresh(Future<bool> Function() doRefresh) async {
    if (_isRefreshing) {
      return _refreshCompleter?.future ?? Future.value(false);
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final success = await doRefresh();
      _refreshCompleter!.complete(success);
      return success;
    } catch (e) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }
}

// ---------------------------------------------------------------------------
// ApiService (NetworkServices with Offline-First)
// ---------------------------------------------------------------------------

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio dio;
  final LocalDbService _db = LocalDbService();

  final List<int> _errorStatusCodes = [400, 401, 403, 422, 500];

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://ef40-103-156-227-0.ngrok-free.app/api',
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

  Future<void> init() async {
    // Handled centrally by LocalDbService
  }

  Future<void> saveDb(String key, String data) async {
    await _db.saveCache(key, data);
  }

  String? getDataDb(String key) {
    return _db.getCache(key);
  }

  // ── Public Generic HTTP Methods (Offline-First) ──────────────────────────

  Future<NetworkResult<T>> getData<T>({
    required String uri,
    required String dbKey,
    required T Function(String) fromJson,
    T? Function(T local, T network)? combineData,
    DataSource dataSource = DataSource.staleWhileRevalidate,
    Map<String, String>? headers,
    HeaderStrategy headerStrategy = HeaderStrategy.global,
    Duration? timeout,
    bool requiresAuth = true,
    bool alreadyRetried = false,

    /// Called with fresh network data after cache is returned (SWR only).
    void Function(T freshData)? onRefreshed,
  }) async {
    return _run<T>(
      dbKey: dbKey,
      fromJson: fromJson,
      dataSource: dataSource,
      onRefreshed: onRefreshed,
      makeRequest: () => dio.get(
        uri,
        options: Options(
          headers: _resolveHeaders(
            strategy: headerStrategy,
            custom: headers,
          ),
          receiveTimeout: timeout,
        ),
      ),
      onSuccess: (response) async {
        final bodyStr = response.data is String
            ? response.data as String
            : jsonEncode(response.data);
        final networkData = fromJson(bodyStr);
        if (dbKey.isNotEmpty) {
          if (combineData != null) {
            final cached = _readCache(dbKey, fromJson);
            if (cached != null) {
              final merged = combineData(cached, networkData) ?? networkData;
              await saveDb(dbKey, jsonEncode(merged));
              return merged;
            }
          }
          await saveDb(dbKey, bodyStr);
        }
        return networkData;
      },
      retry: () => getData<T>(
        uri: uri,
        dbKey: dbKey,
        fromJson: fromJson,
        combineData: combineData,
        dataSource: DataSource.networkOnly,
        headers: headers,
        headerStrategy: headerStrategy,
        timeout: timeout,
        requiresAuth: requiresAuth,
        alreadyRetried: true,
      ),
      requiresAuth: requiresAuth,
      alreadyRetried: alreadyRetried,
    );
  }

  Future<NetworkResult<T>> postData<T>({
    required String uri,
    required String dbKey,
    required T Function(String) fromJson,
    dynamic params,
    DataSource dataSource = DataSource.networkOnly,
    Map<String, String>? customHeader,
    HeaderStrategy headerStrategy = HeaderStrategy.global,
    Duration? timeout,
    bool requiresAuth = true,
    bool alreadyRetried = false,
  }) async {
    return _run<T>(
      dbKey: dbKey,
      fromJson: fromJson,
      dataSource: dataSource,
      makeRequest: () => dio.post(
        uri,
        data: params,
        options: Options(
          headers: _resolveHeaders(
            strategy: headerStrategy,
            custom: customHeader,
          ),
          receiveTimeout: timeout,
        ),
      ),
      onSuccess: (response) async {
        final bodyStr = response.data is String
            ? response.data as String
            : jsonEncode(response.data);
        final data = fromJson(bodyStr);
        if (dbKey.isNotEmpty) await saveDb(dbKey, bodyStr);
        return data;
      },
      retry: () => postData<T>(
        uri: uri,
        dbKey: dbKey,
        fromJson: fromJson,
        params: params,
        dataSource: DataSource.networkOnly,
        customHeader: customHeader,
        headerStrategy: headerStrategy,
        timeout: timeout,
        requiresAuth: requiresAuth,
        alreadyRetried: true,
      ),
      requiresAuth: requiresAuth,
      alreadyRetried: alreadyRetried,
    );
  }

  Future<NetworkResult<T>> putData<T>({
    required String uri,
    required String dbKey,
    required T Function(String) fromJson,
    dynamic params,
    DataSource dataSource = DataSource.networkOnly,
    Map<String, String>? customHeader,
    HeaderStrategy headerStrategy = HeaderStrategy.global,
    Duration? timeout,
    bool requiresAuth = true,
    bool alreadyRetried = false,
  }) async {
    return _run<T>(
      dbKey: dbKey,
      fromJson: fromJson,
      dataSource: dataSource,
      makeRequest: () => dio.put(
        uri,
        data: params,
        options: Options(
          headers: _resolveHeaders(
            strategy: headerStrategy,
            custom: customHeader,
          ),
          receiveTimeout: timeout,
        ),
      ),
      onSuccess: (response) async {
        final bodyStr = response.data is String
            ? response.data as String
            : jsonEncode(response.data);
        final data = fromJson(bodyStr);
        if (dbKey.isNotEmpty) await saveDb(dbKey, bodyStr);
        return data;
      },
      retry: () => putData<T>(
        uri: uri,
        dbKey: dbKey,
        fromJson: fromJson,
        params: params,
        dataSource: DataSource.networkOnly,
        customHeader: customHeader,
        headerStrategy: headerStrategy,
        timeout: timeout,
        requiresAuth: requiresAuth,
        alreadyRetried: true,
      ),
      requiresAuth: requiresAuth,
      alreadyRetried: alreadyRetried,
    );
  }

  Future<NetworkResult<T>> patchData<T>({
    required String uri,
    required String dbKey,
    required T Function(String) fromJson,
    dynamic params,
    DataSource dataSource = DataSource.networkOnly,
    Map<String, String>? customHeader,
    HeaderStrategy headerStrategy = HeaderStrategy.global,
    Duration? timeout,
    bool requiresAuth = true,
    bool alreadyRetried = false,
  }) async {
    return _run<T>(
      dbKey: dbKey,
      fromJson: fromJson,
      dataSource: dataSource,
      makeRequest: () => dio.patch(
        uri,
        data: params,
        options: Options(
          headers: _resolveHeaders(
            strategy: headerStrategy,
            custom: customHeader,
          ),
          receiveTimeout: timeout,
        ),
      ),
      onSuccess: (response) async {
        final bodyStr = response.data is String
            ? response.data as String
            : jsonEncode(response.data);
        final data = fromJson(bodyStr);
        if (dbKey.isNotEmpty) await saveDb(dbKey, bodyStr);
        return data;
      },
      retry: () => patchData<T>(
        uri: uri,
        dbKey: dbKey,
        fromJson: fromJson,
        params: params,
        dataSource: DataSource.networkOnly,
        customHeader: customHeader,
        headerStrategy: headerStrategy,
        timeout: timeout,
        requiresAuth: requiresAuth,
        alreadyRetried: true,
      ),
      requiresAuth: requiresAuth,
      alreadyRetried: alreadyRetried,
    );
  }

  Future<NetworkResult<T>> deleteData<T>({
    required String uri,
    required String dbKey,
    required T Function(String) fromJson,
    dynamic params,
    DataSource dataSource = DataSource.networkOnly,
    Map<String, String>? customHeader,
    HeaderStrategy headerStrategy = HeaderStrategy.global,
    Duration? timeout,
    bool requiresAuth = true,
    bool alreadyRetried = false,
  }) async {
    return _run<T>(
      dbKey: dbKey,
      fromJson: fromJson,
      dataSource: dataSource,
      makeRequest: () => dio.delete(
        uri,
        data: params,
        options: Options(
          headers: _resolveHeaders(
            strategy: headerStrategy,
            custom: customHeader,
          ),
          receiveTimeout: timeout,
        ),
      ),
      onSuccess: (response) async {
        final bodyStr = response.data is String
            ? response.data as String
            : jsonEncode(response.data);
        final data = fromJson(bodyStr);
        if (dbKey.isNotEmpty) await saveDb(dbKey, bodyStr);
        return data;
      },
      retry: () => deleteData<T>(
        uri: uri,
        dbKey: dbKey,
        fromJson: fromJson,
        params: params,
        dataSource: DataSource.networkOnly,
        customHeader: customHeader,
        headerStrategy: headerStrategy,
        timeout: timeout,
        requiresAuth: requiresAuth,
        alreadyRetried: true,
      ),
      requiresAuth: requiresAuth,
      alreadyRetried: alreadyRetried,
    );
  }

  // ── Core Execution Engine ────────────────────────────────────────────────

  Future<NetworkResult<T>> _run<T>({
    required String dbKey,
    required T Function(String) fromJson,
    required DataSource dataSource,
    required Future<Response> Function() makeRequest,
    required Future<T> Function(Response) onSuccess,
    required Future<NetworkResult<T>> Function() retry,
    required bool requiresAuth,
    required bool alreadyRetried,
    void Function(T freshData)? onRefreshed,
  }) async {
    // 1. Cache-only
    if (dataSource == DataSource.cacheOnly) {
      final cached = _readCache(dbKey, fromJson);
      if (cached != null) return NetworkSuccess(cached);
      return const NetworkFailure(message: 'No cached data available');
    }

    // 2. Stale-while-revalidate: return cache immediately, refresh in background
    if (dataSource == DataSource.staleWhileRevalidate) {
      final cached = _readCache(dbKey, fromJson);
      if (cached != null) {
        // Fire network request in the background
        unawaited(() async {
          try {
            final response = await makeRequest();
            if (_isResponseValid(response)) {
              final fresh = await onSuccess(response);
              onRefreshed?.call(fresh);
            }
          } catch (e) {
            log('SWR background refresh failed for $dbKey: $e');
          }
        }());
        return NetworkSuccess(cached);
      }
      // No cache — fall through to normal network request
    }

    // 3. Cache-first: return cache if available, skip network
    if (dataSource == DataSource.staleWhileRevalidate) {
      final cached = _readCache(dbKey, fromJson);
      if (cached != null) return NetworkSuccess(cached);
    }

    // 3. Network request
    try {
      final response = await makeRequest();

      if (_isResponseValid(response)) {
        final data = await onSuccess(response);
        return NetworkSuccess(data);
      }

      if (_errorStatusCodes.contains(response.statusCode)) {
        if (response.statusCode == 401 && requiresAuth && !alreadyRetried) {
          AuthService().clearSession();
          return const NetworkFailure(
            message: 'Authentication failed',
            statusCode: 401,
          );
        }

        try {
          final bodyStr = response.data is String
              ? response.data as String
              : jsonEncode(response.data);
          final errData = fromJson(bodyStr);
          return NetworkSuccess(errData);
        } catch (_) {
          return NetworkFailure(
            message: 'Request error (${response.statusCode})',
            statusCode: response.statusCode,
          );
        }
      }

      return NetworkFailure(
        message: 'Unexpected status code',
        statusCode: response.statusCode,
      );
    } catch (e) {
      log('Network error: $e');

      // 4. networkFirst: fall back to cache on failure
      if (dataSource == DataSource.staleWhileRevalidate && dbKey.isNotEmpty) {
        final cached = _readCache(dbKey, fromJson);
        if (cached != null) {
          log('Returning cached data for $dbKey after network failure');
          return NetworkSuccess(cached);
        }
      }

      return NetworkFailure(message: 'Network error', error: e);
    }
  }

  bool _isResponseValid(Response? response) {
    if (response == null) return false;
    return response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204;
  }

  T? _readCache<T>(String dbKey, T Function(String) fromJson) {
    if (dbKey.isEmpty) return null;
    try {
      final raw = getDataDb(dbKey);
      if (raw == null) return null;
      return fromJson(raw);
    } catch (e) {
      log('Cache read failed for $dbKey: $e');
      return null;
    }
  }

  Map<String, String>? _resolveHeaders({
    required HeaderStrategy strategy,
    Map<String, String>? custom,
  }) {
    switch (strategy) {
      case HeaderStrategy.global:
        final token = AuthService().getToken();
        return {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        };
      case HeaderStrategy.custom:
        return custom;
      case HeaderStrategy.none:
        return null;
    }
  }

  // ── Existing Endpoints (Preserved for full backward compatibility) ─────────

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
    double? intensity,
    String? title,
    String? note,
  }) async {
    return await dio.post('/moods', data: {
      'mood': mood,
      'emotions': emotions,
      if (intensity != null) 'intensity': intensity,
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
    double? intensity,
    String? title,
    String? note,
  }) async {
    return await dio.put('/moods/$id', data: {
      if (mood != null) 'mood': mood,
      if (emotions != null) 'emotions': emotions,
      if (intensity != null) 'intensity': intensity,
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

  // Gamification Endpoints
  Future<Response> getGamificationProfile() async {
    return await dio.get('/gamification/profile');
  }

  Future<Response> getGamificationBadges() async {
    return await dio.get('/gamification/badges');
  }

  Future<Response> getGamificationChallenges() async {
    return await dio.get('/gamification/challenges');
  }

  Future<Response> getGamificationLeaderboard() async {
    return await dio.get('/gamification/leaderboard');
  }
}
