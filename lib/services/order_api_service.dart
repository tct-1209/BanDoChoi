import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/order.dart';

class OrderApiService {
  static final http.Client _client = http.Client();

  // Get all orders
  static Future<ApiResponse<List<Order>>> getAllOrders() async {
    try {
      final url = '${AppConfig.baseUrl}/orders/all';
      print('DEBUG: Calling API: $url');
      
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('DEBUG: Orders Response status: ${response.statusCode}');
      print('DEBUG: Orders Response body: ${response.body}');
      
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = responseData;
        final orders = ordersJson.map((json) => Order.fromJson(json)).toList();
        
        // Sắp xếp theo thứ tự mới nhất đến cũ nhất
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        return ApiResponse<List<Order>>(
          success: true,
          message: 'Lấy danh sách đơn hàng thành công',
          data: orders,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<List<Order>>(
          success: false,
          message: 'Lấy danh sách đơn hàng thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<List<Order>>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<List<Order>>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<List<Order>>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Get order by ID
  static Future<ApiResponse<Order>> getOrderById(String id) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConfig.baseUrl}/orders/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Order>(
          success: true,
          message: 'Lấy thông tin đơn hàng thành công',
          data: Order.fromJson(responseData),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Order>(
          success: false,
          message: responseData['message'] ?? 'Lấy thông tin đơn hàng thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<Order>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<Order>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<Order>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Create order
  static Future<ApiResponse<Order>> createOrder({
    required int userId,
    required List<OrderItem> items,
    required double totalPrice,
    String? status,
    String? paymentStatus,
    int? voucherId,
    String? note,
    Map<String, dynamic>? address,
  }) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.createOrderEndpoint}';
      final body = {
        'user_Id': userId,
        'total_price': totalPrice,
        if (voucherId != null) 'voucher_Id': voucherId,
        'status': status ?? 'pending',
        'payment_status': paymentStatus ?? 'pending',
        if (note != null) 'note': note,
        if (address != null) 'address': address,
        'items': items
            .map((e) => {
                  'menuItem_Id': e.productId,
                  'quantity': e.quantity,
                  'price': e.price,
                })
            .toList(),
      };

      final response = await _client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResponse<Order>(
          success: true,
          message: responseData['message'] ?? 'Tạo đơn hàng thành công',
          data: Order.fromJson(responseData['order'] ?? responseData),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Order>(
          success: false,
          message: responseData['message'] ?? 'Tạo đơn hàng thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<Order>(success: false, message: 'Không có kết nối internet');
    } on HttpException {
      return ApiResponse<Order>(success: false, message: 'Lỗi kết nối server');
    } catch (e) {
      return ApiResponse<Order>(success: false, message: 'Có lỗi xảy ra: ${e.toString()}');
    }
  }

  // Get orders by user ID
  static Future<ApiResponse<List<Order>>> getOrdersByUserId(String userId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConfig.baseUrl}/orders/user/$userId'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = responseData;
        final orders = ordersJson.map((json) => Order.fromJson(json)).toList();
        
        // Sắp xếp theo thứ tự mới nhất đến cũ nhất
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        return ApiResponse<List<Order>>(
          success: true,
          message: 'Lấy đơn hàng của người dùng thành công',
          data: orders,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<List<Order>>(
          success: false,
          message: responseData['message'] ?? 'Lấy đơn hàng của người dùng thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<List<Order>>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<List<Order>>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<List<Order>>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Update order status
  static Future<ApiResponse<Order>> updateOrderStatus({
    required String id,
    required String status,
    required String paymentStatus,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('${AppConfig.baseUrl}/orders/update/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'status': status,
              'payment_status': paymentStatus,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Order>(
          success: true,
          message: responseData['message'] ?? 'Cập nhật đơn hàng thành công',
          data: Order.fromJson(responseData['order']),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Order>(
          success: false,
          message: responseData['message'] ?? 'Cập nhật đơn hàng thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<Order>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<Order>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<Order>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Cancel order
  static Future<ApiResponse<Order>> cancelOrder(String id) async {
    try {
      final response = await _client
          .put(
            Uri.parse('${AppConfig.baseUrl}/orders/cancel/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Order>(
          success: true,
          message: responseData['message'] ?? 'Hủy đơn hàng thành công',
          data: Order.fromJson(responseData['order']),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Order>(
          success: false,
          message: responseData['message'] ?? 'Hủy đơn hàng thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<Order>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<Order>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<Order>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Delete order
  static Future<ApiResponse<void>> deleteOrder(String id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('${AppConfig.baseUrl}/orders/delete/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message'] ?? 'Xóa đơn hàng thành công',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message'] ?? 'Xóa đơn hàng thất bại',
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

  // Get revenue statistics
  static Future<ApiResponse<Map<String, dynamic>>> getRevenue() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConfig.baseUrl}/orders/revenue'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Lấy thống kê doanh thu thành công',
          data: responseData,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: responseData['message'] ?? 'Lấy thống kê doanh thu thất bại',
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

  static void dispose() {
    _client.close();
  }
}

// Generic API Response class
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
}
