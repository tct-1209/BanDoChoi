# 🎮 Toy Shop Flutter App - Authentication Integration

## 📋 Tổng quan

Đã hoàn thành tích hợp chức năng đăng nhập/đăng ký với backend API thực. App Android giờ đây có thể kết nối với backend Node.js và thực hiện authentication đầy đủ.

## 🚀 Tính năng đã hoàn thành

### ✅ Authentication System
- **Đăng nhập**: Sử dụng số điện thoại + mật khẩu
- **Đăng ký**: Form đầy đủ với validation
- **Phân quyền**: Admin/Customer với navigation khác nhau
- **Persistent Login**: Lưu trữ token và user data
- **Error Handling**: Xử lý lỗi network và validation

### ✅ Backend Integration
- **API Service**: Kết nối với backend Node.js
- **Config Management**: Quản lý địa chỉ backend tập trung
- **JWT Token**: Authentication với token
- **HTTP Client**: Sử dụng http package

## 📁 Cấu trúc file mới

```
lib/
├── config/
│   └── app_config.dart          # Cấu hình backend URLs và endpoints
├── services/
│   └── auth_api_service.dart    # API service cho authentication
├── models/
│   └── user.dart               # User model cập nhật để match backend
├── providers/
│   └── auth_provider.dart      # AuthProvider với API integration
└── screens/auth/
    ├── login_screen.dart       # Login screen với phone number
    └── register_screen.dart    # Register screen đầy đủ
```

## 🔧 Cấu hình

### Backend Configuration
File `lib/config/app_config.dart` chứa tất cả cấu hình:

```dart
class AppConfig {
  static const String baseUrl = 'http://localhost:5000/api';
  static const String loginEndpoint = '/users/login';
  static const String registerEndpoint = '/users/register';
  // ... các endpoints khác
}
```

### Dependencies
Đã thêm vào `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0  # Cho API calls
```

## 🎯 Cách sử dụng

### 1. Chạy Backend
```bash
cd source_code/backend
npm install
npm run start:dev
```

### 2. Chạy Flutter App
```bash
cd source_code/toy-shop-flutter
flutter pub get
flutter run
```

### 3. Test Accounts
- **Admin**: `0123456789` / `admin123`
- **Customer**: `0987654321` / `user123`

## 🔄 API Endpoints được sử dụng

### Authentication
- `POST /api/users/login` - Đăng nhập
- `POST /api/users/register` - Đăng ký
- `POST /api/users/forgot-password` - Quên mật khẩu
- `POST /api/users/reset-password` - Reset mật khẩu
- `GET /api/users/get/:id` - Lấy thông tin user
- `PUT /api/users/update/:id` - Cập nhật profile
- `PUT /api/users/change-password/:id` - Đổi mật khẩu

## 🎨 UI/UX Features

### Login Screen
- Input số điện thoại thay vì email
- Validation đầy đủ
- Loading state với Provider
- Error handling với SnackBar
- Demo accounts hiển thị

### Register Screen
- Form đầy đủ: Họ tên, SĐT, Email, Địa chỉ, Mật khẩu
- Validation real-time
- Confirm password
- Success/Error feedback
- Navigation back to login

### Navigation
- **Admin**: Trang chủ → Quản lý → Tài khoản
- **Customer**: Trang chủ → Yêu thích → Tài khoản
- Auto-redirect dựa trên role

## 🔐 Security Features

- **JWT Token**: Secure authentication
- **Password Hashing**: Backend sử dụng bcrypt
- **Input Validation**: Client-side và server-side
- **Error Messages**: Không expose sensitive info
- **Token Storage**: Secure storage với SharedPreferences

## 🚧 Next Steps

1. **Product Integration**: Kết nối với API sản phẩm
2. **Cart Management**: Giỏ hàng với backend
3. **Order System**: Đặt hàng và thanh toán
4. **Real-time Updates**: Socket.IO integration
5. **Push Notifications**: Firebase integration

## 🐛 Troubleshooting

### Common Issues
1. **Connection Error**: Kiểm tra backend đang chạy
2. **CORS Error**: Backend đã config CORS
3. **Token Expired**: App sẽ tự động logout
4. **Network Timeout**: Config timeout trong AppConfig

### Debug Mode
```dart
// Trong auth_api_service.dart
debugPrint('API Response: $responseData');
```

## 📱 Testing

### Manual Testing
1. Test đăng ký tài khoản mới
2. Test đăng nhập với tài khoản có sẵn
3. Test phân quyền admin/customer
4. Test logout và persistent login
5. Test error handling (network off, wrong credentials)

### Test Cases
- ✅ Valid login credentials
- ✅ Invalid login credentials  
- ✅ Registration with valid data
- ✅ Registration with duplicate phone
- ✅ Admin vs Customer navigation
- ✅ Token persistence
- ✅ Network error handling

---

**🎉 Chức năng authentication đã hoàn thành và sẵn sàng để test!**
