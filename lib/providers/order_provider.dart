import 'package:flutter/foundation.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [
    // Mock orders for demo
    Order(
      id: 1,
      userId: 2,
      totalPrice: 450000.0,
      status: 'delivered',
      paymentStatus: 'paid',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      items: [
        OrderItem(
          id: 1,
          orderId: 1,
          productId: 1,
          quantity: 2,
          price: 225000.0,
        ),
        OrderItem(
          id: 2,
          orderId: 1,
          productId: 2,
          quantity: 1,
          price: 225000.0,
        ),
      ],
    ),
    Order(
      id: 2,
      userId: 2,
      totalPrice: 300000.0,
      status: 'shipped',
      paymentStatus: 'paid',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      items: [
        OrderItem(
          id: 3,
          orderId: 2,
          productId: 3,
          quantity: 1,
          price: 300000.0,
        ),
      ],
    ),
  ];

  List<Order> get orders => _orders;

  List<Order> getOrdersByUserId(int userId) {
    final userOrders = _orders.where((order) => order.userId == userId).toList();
    // Sắp xếp theo thứ tự mới nhất đến cũ nhất
    userOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return userOrders;
  }

  Future<void> createOrder(Order order) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _orders.insert(0, order);
    notifyListeners();
  }

  Future<void> cancelOrder(int orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index >= 0) {
      final order = _orders[index];
      _orders[index] = order.copyWith(
        status: 'cancelled',
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
}