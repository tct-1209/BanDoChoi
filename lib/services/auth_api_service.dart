import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['message'] != null,
      message: json['message'] ?? 'Unknown error',
      data: json['user'] != null && fromJsonT != null ? fromJsonT(json['user']) : null,
      statusCode: 200,
    );
  }
}

class AuthApiService {
  static final http.Client _client = http.Client();

  // Login
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConfig.baseUrl}${AppConfig.loginEndpoint}'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'phone_number': phoneNumber,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: responseData['message'] ?? 'Đăng nhập thành công',
          data: {
            'user': responseData['user'],
            'token': responseData['token'],
          },
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: responseData['message'] ?? 'Đăng nhập thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Register
  static Future<ApiResponse<Map<String, dynamic>>> register({
    required String phoneNumber,
    required String password,
    required String email,
    required String fullname,
    String? address,
    String roleName = 'customer',
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConfig.baseUrl}${AppConfig.registerEndpoint}'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'phone_number': phoneNumber,
              'password': password,
              'email': email,
              'fullname': fullname,
              'address': address,
              'role_name': roleName,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: responseData['message'] ?? 'Đăng ký thành công',
          data: {
            'user': responseData['user'],
          },
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: responseData['message'] ?? 'Đăng ký thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Forgot Password
  static Future<ApiResponse<void>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConfig.baseUrl}${AppConfig.forgotPasswordEndpoint}'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'email': email,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message'] ?? 'Email đã được gửi',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message'] ?? 'Gửi email thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<void>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<void>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Reset Password
  static Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConfig.baseUrl}${AppConfig.resetPasswordEndpoint}'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'token': token,
              'newPassword': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message'] ?? 'Đặt lại mật khẩu thành công',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message'] ?? 'Đặt lại mật khẩu thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<void>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<void>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Get User Profile
  static Future<ApiResponse<User>> getUserProfile({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConfig.baseUrl}${AppConfig.getUserProfileEndpoint}/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<User>(
          success: true,
          message: 'Lấy thông tin thành công',
          data: User.fromJson(responseData),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: responseData['message'] ?? 'Lấy thông tin thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<User>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<User>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Update User Profile
  static Future<ApiResponse<User>> updateUserProfile({
    required String userId,
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('${AppConfig.baseUrl}${AppConfig.updateUserProfileEndpoint}/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(userData),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<User>(
          success: true,
          message: responseData['message'] ?? 'Cập nhật thành công',
          data: User.fromJson(responseData['user']),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: responseData['message'] ?? 'Cập nhật thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<User>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<User>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Change Password
  static Future<ApiResponse<void>> changePassword({
    required String userId,
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('${AppConfig.baseUrl}${AppConfig.changePasswordEndpoint}/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message'] ?? 'Đổi mật khẩu thành công',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message'] ?? 'Đổi mật khẩu thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<void>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<void>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  static void dispose() {
    _client.close();
  }
}
