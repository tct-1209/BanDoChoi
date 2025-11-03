class AppConfig {
  // Backend Configuration - Sử dụng IP thực cho Android emulator
  static const String baseUrl = 'http://10.0.2.2:5000/api';  // IP cho Android emulator
  static const String baseUrlWithoutApi = 'http://10.0.2.2:5000';
  
  // Nếu chạy trên thiết bị thật, thay đổi thành IP máy tính:
  // static const String baseUrl = 'http://192.168.1.100:5000/api';  // Thay IP máy tính
  // static const String baseUrlWithoutApi = 'http://192.168.1.100:5000';
  
  // API Endpoints
  static const String loginEndpoint = '/users/login';
  static const String registerEndpoint = '/users/register';
  static const String forgotPasswordEndpoint = '/users/forgot-password';
  static const String resetPasswordEndpoint = '/users/reset-password';
  static const String getUserProfileEndpoint = '/users/get';
  static const String updateUserProfileEndpoint = '/users/update';
  static const String changePasswordEndpoint = '/users/change-password';
  
  // Product Endpoints
  static const String getAllProductsEndpoint = '/menu-items/all';
  static const String getProductByIdEndpoint = '/menu-items';
  static const String getAllCategoriesEndpoint = '/category/all';
  
  // Cart Endpoints
  static const String getCartEndpoint = '/cart';
  static const String addToCartEndpoint = '/cart';
  static const String updateCartItemEndpoint = '/cart';
  static const String removeFromCartEndpoint = '/cart';
  static const String clearCartEndpoint = '/cart';
  
  // Order Endpoints
  static const String getAllOrdersEndpoint = '/orders/all';
  static const String getUserOrdersEndpoint = '/orders/user';
  static const String createOrderEndpoint = '/orders/create';
  static const String updateOrderEndpoint = '/orders/update';
  static const String cancelOrderEndpoint = '/orders/cancel';
  
  // Payment Endpoints
  static const String createPaymentEndpoint = '/payment/create';
  static const String vnpayInitiateEndpoint = '/payment/vnpay_initiate';
  
  // Review Endpoints
  static const String getReviewsEndpoint = '/review/get';
  
  // Voucher Endpoints
  static const String checkVoucherEndpoint = '/voucher/check';
  
  // App Settings
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // User Roles
  static const String customerRole = 'customer';
  static const String adminRole = 'admin';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
}
