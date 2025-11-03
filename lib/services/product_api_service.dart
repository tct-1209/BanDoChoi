import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/product.dart';

class ProductApiService {
  static final http.Client _client = http.Client();

  // Get all products
  static Future<ApiResponse<List<Product>>> getAllProducts() async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.getAllProductsEndpoint}';
      print('DEBUG: Calling API: $url'); // Debug log
      
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('DEBUG: Response status: ${response.statusCode}'); // Debug log
      print('DEBUG: Response body: ${response.body}'); // Debug log
      
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = responseData;
        final products = productsJson.map((json) => Product.fromJson(json)).toList();
        
        return ApiResponse<List<Product>>(
          success: true,
          message: 'Lấy danh sách sản phẩm thành công',
          data: products,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<List<Product>>(
          success: false,
          message: 'Lấy danh sách sản phẩm thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<List<Product>>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<List<Product>>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<List<Product>>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Get product by ID
  static Future<ApiResponse<Product>> getProductById(String id) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConfig.baseUrl}/menu-items/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Product>(
          success: true,
          message: 'Lấy thông tin sản phẩm thành công',
          data: Product.fromJson(responseData),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Product>(
          success: false,
          message: responseData['message'] ?? 'Lấy thông tin sản phẩm thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<Product>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<Product>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<Product>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Create product
  static Future<ApiResponse<Product>> createProduct({
    required String name,
    required double price,
    required int categoryId,
    required String status,
    String? imageUrl,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConfig.baseUrl}/menu-items/create'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'name': name,
              'price': price,
              'cat_Id': categoryId,
              'status': status,
              'img': imageUrl,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<Product>(
          success: true,
          message: responseData['message'] ?? 'Tạo sản phẩm thành công',
          data: Product.fromJson(responseData['menuItem']),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Product>(
          success: false,
          message: responseData['message'] ?? 'Tạo sản phẩm thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<Product>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<Product>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<Product>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Update product
  static Future<ApiResponse<Product>> updateProduct({
    required String id,
    required String name,
    required double price,
    required int categoryId,
    required String status,
    String? imageUrl,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('${AppConfig.baseUrl}/menu-items/update/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'name': name,
              'price': price,
              'cat_Id': categoryId,
              'status': status,
              'img': imageUrl,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Product>(
          success: true,
          message: responseData['message'] ?? 'Cập nhật sản phẩm thành công',
          data: Product.fromJson(responseData['menuItem']),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Product>(
          success: false,
          message: responseData['message'] ?? 'Cập nhật sản phẩm thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<Product>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<Product>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<Product>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Delete product
  static Future<ApiResponse<void>> deleteProduct(String id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('${AppConfig.baseUrl}/menu-items/delete/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message'] ?? 'Xóa sản phẩm thành công',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message'] ?? 'Xóa sản phẩm thất bại',
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

class CategoryApiService {
  static final http.Client _client = http.Client();

  // Get all categories
  static Future<ApiResponse<List<Category>>> getAllCategories() async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.getAllCategoriesEndpoint}';
      print('DEBUG: Calling API: $url'); // Debug log
      
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('DEBUG: Categories Response status: ${response.statusCode}'); // Debug log
      print('DEBUG: Categories Response body: ${response.body}'); // Debug log
      
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = responseData;
        final categories = categoriesJson.map((json) => Category.fromJson(json)).toList();
        
        return ApiResponse<List<Category>>(
          success: true,
          message: 'Lấy danh sách danh mục thành công',
          data: categories,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<List<Category>>(
          success: false,
          message: 'Lấy danh sách danh mục thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<List<Category>>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<List<Category>>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<List<Category>>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Get category by ID
  static Future<ApiResponse<Category>> getCategoryById(String id) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConfig.baseUrl}/category/get/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Category>(
          success: true,
          message: 'Lấy thông tin danh mục thành công',
          data: Category.fromJson(responseData),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Category>(
          success: false,
          message: responseData['message'] ?? 'Lấy thông tin danh mục thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<Category>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<Category>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<Category>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Create category
  static Future<ApiResponse<Category>> createCategory({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConfig.baseUrl}/category/create'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'name': name,
              'description': description,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<Category>(
          success: true,
          message: responseData['message'] ?? 'Tạo danh mục thành công',
          data: Category.fromJson(responseData['category']),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Category>(
          success: false,
          message: responseData['message'] ?? 'Tạo danh mục thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<Category>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<Category>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<Category>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Update category
  static Future<ApiResponse<Category>> updateCategory({
    required String id,
    required String name,
    String? description,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('${AppConfig.baseUrl}/category/update/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'name': name,
              'description': description,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Category>(
          success: true,
          message: responseData['message'] ?? 'Cập nhật danh mục thành công',
          data: Category.fromJson(responseData['category']),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<Category>(
          success: false,
          message: responseData['message'] ?? 'Cập nhật danh mục thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<Category>(
        success: false,
        message: 'Không có kết nối internet',
      );
    } on HttpException {
      return ApiResponse<Category>(
        success: false,
        message: 'Lỗi kết nối server',
      );
    } catch (e) {
      return ApiResponse<Category>(
        success: false,
        message: 'Có lỗi xảy ra: ${e.toString()}',
      );
    }
  }

  // Delete category
  static Future<ApiResponse<void>> deleteCategory(String id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('${AppConfig.baseUrl}/category/delete/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: responseData['message'] ?? 'Xóa danh mục thành công',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: responseData['message'] ?? 'Xóa danh mục thất bại',
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