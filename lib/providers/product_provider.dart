import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _newProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get newProducts => _newProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all products
  Future<void> loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ProductApiService.getAllProducts();
      if (response.success && response.data != null) {
        _products = response.data!;
        
        // Set featured products (first 6 products)
        _featuredProducts = _products.take(6).toList();
        
        // Set new products (last 6 products)
        _newProducts = _products.length > 6 
            ? _products.sublist(_products.length - 6)
            : _products;
        
        notifyListeners();
      } else {
        setState(() {
          _errorMessage = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get product by ID
  Future<Product?> getProductById(int id) async {
    try {
      final response = await ProductApiService.getProductById(id.toString());
      if (response.success && response.data != null) {
        return response.data!;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    return _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get products by category
  List<Product> getProductsByCategory(int categoryId) {
    return _products.where((product) => product.catId == categoryId).toList();
  }

  // Get active products
  List<Product> get activeProducts {
    return _products.where((product) => product.isActive).toList();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadProducts();
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }
}