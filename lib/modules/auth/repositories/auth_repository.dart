import 'package:dio/dio.dart';
import 'package:moodie/utils/services/api_service.dart';

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  final ApiService _apiService = ApiService();

  Future<String> sendForgotPasswordLink(String email) async {
    try {
      final response = await _apiService.forgotPassword(email: email);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data?['message'] ??
            'We have emailed your password reset link.';
      } else {
        final errorMsg =
            response.data?['message'] ?? 'Failed to send reset link.';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data?['errors'];
        if (errors != null &&
            errors['email'] != null &&
            (errors['email'] as List).isNotEmpty) {
          throw Exception(errors['email'][0].toString());
        }
      }
      final errorMsg = e.response?.data?['message'] ??
          'Failed to send reset link. Please check your email and try again.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.changePassword(
        currentPassword: currentPassword,
        password: newPassword,
        passwordConfirmation: confirmPassword,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data?['message'] ?? 'Password updated successfully.';
      } else {
        final errorMsg =
            response.data?['message'] ?? 'Failed to update password.';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data?['errors'];
        if (errors != null) {
          if (errors['current_password'] != null &&
              (errors['current_password'] as List).isNotEmpty) {
            throw Exception(errors['current_password'][0].toString());
          } else if (errors['password'] != null &&
              (errors['password'] as List).isNotEmpty) {
            throw Exception(errors['password'][0].toString());
          }
        }
      }
      final errorMsg = e.response?.data?['message'] ??
          'Failed to update password. Please try again.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> deleteAccount(String password) async {
    try {
      final response = await _apiService.deleteUserAccount(password: password);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.data?['message'] ?? 'Account deleted successfully.';
      } else {
        final errorMsg =
            response.data?['message'] ?? 'Failed to delete account.';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data?['errors'];
        if (errors != null &&
            errors['password'] != null &&
            (errors['password'] as List).isNotEmpty) {
          throw Exception(errors['password'][0].toString());
        }
      }
      final errorMsg = e.response?.data?['message'] ??
          'Failed to delete account. Please try again.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Alias for backward compatibility if referenced
  Future<String> forgotPassword(String email) => sendForgotPasswordLink(email);
}
