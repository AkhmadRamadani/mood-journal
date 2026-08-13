import 'package:moodie/models/user_model.dart';
import 'package:moodie/utils/services/local_db_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String tokenKey = 'token';
  static const String userKey = 'user_data';

  final LocalDbService _db = LocalDbService();

  Future<void> init() async {
    // LocalDbService handles initialization centrally
  }

  String? getToken() {
    return _db.getAuth(tokenKey) as String?;
  }

  Future<void> saveToken(String token) async {
    await _db.saveAuth(tokenKey, token);
  }

  UserModel? getUser() {
    final data = _db.getAuth(userKey);
    if (data != null && data is Map) {
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<void> saveUser(UserModel user) async {
    await _db.saveAuth(userKey, user.toJson());
  }

  Future<void> clearSession() async {
    await _db.deleteAuth(tokenKey);
    await _db.deleteAuth(userKey);
  }

  bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}
