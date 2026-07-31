import 'package:hive_flutter/hive_flutter.dart';
import 'package:moodie/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String authBoxName = 'auth';
  static const String tokenKey = 'token';
  static const String userKey = 'user_data';

  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(authBoxName);
  }

  Box get box {
    if (_box == null || !_box!.isOpen) {
      _box = Hive.box(authBoxName);
    }
    return _box!;
  }

  String? getToken() {
    return box.get(tokenKey);
  }

  Future<void> saveToken(String token) async {
    await box.put(tokenKey, token);
  }

  UserModel? getUser() {
    final data = box.get(userKey);
    if (data != null && data is Map) {
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<void> saveUser(UserModel user) async {
    await box.put(userKey, user.toJson());
  }

  Future<void> clearSession() async {
    await box.delete(tokenKey);
    await box.delete(userKey);
  }

  bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}
