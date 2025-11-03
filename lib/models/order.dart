// Import User và Product từ các file khác
import 'user.dart';
import 'product.dart';

class Order {
  final int id;
  final int userId;
  final double totalPrice;
  final int? voucherId;
  final String status;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final Voucher? voucher;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.userId,
    required this.totalPrice,
    this.voucherId,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.voucher,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      userId: json['user_Id'] ?? 0,
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      voucherId: json['voucher_Id'],
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      user: json['User'] != null ? User.fromJson(json['User']) : null,
      voucher: json['Voucher'] != null ? Voucher.fromJson(json['Voucher']) : null,
      items: json['OrderItems'] != null 
          ? (json['OrderItems'] as List).map((item) => OrderItem.fromJson(item)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_Id': userId,
      'total_price': totalPrice,
      'voucher_Id': voucherId,
      'status': status,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'User': user?.toJson(),
      'Voucher': voucher?.toJson(),
      'OrderItems': items?.map((item) => item.toJson()).toList(),
    };
  }

  Order copyWith({
    int? id,
    int? userId,
    double? totalPrice,
    int? voucherId,
    String? status,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    Voucher? voucher,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalPrice: totalPrice ?? this.totalPrice,
      voucherId: voucherId ?? this.voucherId,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      voucher: voucher ?? this.voucher,
      items: items ?? this.items,
    );
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isProcessing => status == 'processing';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

  bool get isPaid => paymentStatus == 'paid';
  bool get isUnpaid => paymentStatus == 'pending';

  String get statusText {
    switch (status) {
      case 'pending': return 'Chờ xác nhận';
      case 'confirmed': return 'Đã xác nhận';
      case 'processing': return 'Đang xử lý';
      case 'shipped': return 'Đang giao';
      case 'delivered': return 'Đã giao';
      case 'cancelled': return 'Đã hủy';
      default: return status;
    }
  }

  String get paymentStatusText {
    switch (paymentStatus) {
      case 'pending': return 'Chưa thanh toán';
      case 'paid': return 'Đã thanh toán';
      case 'failed': return 'Thanh toán thất bại';
      default: return paymentStatus;
    }
  }

  String get formattedPrice => '${totalPrice.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
    (Match m) => '${m[1]},'
  )} VNĐ';
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_Id'] ?? 0,
      productId: json['product_Id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      product: json['Product'] != null ? Product.fromJson(json['Product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_Id': orderId,
      'product_Id': productId,
      'quantity': quantity,
      'price': price,
      'Product': product?.toJson(),
    };
  }
}

class Voucher {
  final int id;
  final String code;
  final double discount;
  final String type;
  final DateTime? expiryDate;

  Voucher({
    required this.id,
    required this.code,
    required this.discount,
    required this.type,
    this.expiryDate,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      discount: double.tryParse(json['discount'].toString()) ?? 0.0,
      type: json['type'] ?? 'percentage',
      expiryDate: json['expiry_date'] != null 
          ? DateTime.parse(json['expiry_date']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount': discount,
      'type': type,
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }
}