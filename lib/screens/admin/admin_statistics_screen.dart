import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../services/order_api_service.dart';
import '../../services/product_api_service.dart';

class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  
  // Statistics data
  int _totalOrders = 0;
  int _totalProducts = 0;
  int _pendingOrders = 0;
  int _deliveredOrders = 0;
  double _totalRevenue = 0.0;
  List<Order> _recentOrders = [];
  Map<String, int> _orderStatusStats = {};
  Map<String, double> _monthlyRevenue = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load orders
      final ordersResponse = await OrderApiService.getAllOrders();
      if (ordersResponse.success && ordersResponse.data != null) {
        final orders = ordersResponse.data!;
        setState(() {
          _totalOrders = orders.length;
          _pendingOrders = orders.where((o) => o.isPending).length;
          _deliveredOrders = orders.where((o) => o.isDelivered).length;
          _totalRevenue = orders.where((o) => o.isDelivered).fold(0.0, (sum, o) => sum + o.totalPrice);
          // Sắp xếp theo thứ tự mới nhất và lấy 5 đơn hàng gần nhất
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _recentOrders = orders.take(5).toList();
          
          // Calculate status statistics
          _orderStatusStats = {
            'pending': orders.where((o) => o.isPending).length,
            'confirmed': orders.where((o) => o.isConfirmed).length,
            'processing': orders.where((o) => o.isProcessing).length,
            'shipped': orders.where((o) => o.isShipped).length,
            'delivered': orders.where((o) => o.isDelivered).length,
            'cancelled': orders.where((o) => o.isCancelled).length,
          };
          
          // Calculate monthly revenue (simplified)
          _monthlyRevenue = _calculateMonthlyRevenue(orders);
        });
      }

      // Load products
      final productsResponse = await ProductApiService.getAllProducts();
      if (productsResponse.success && productsResponse.data != null) {
        setState(() {
          _totalProducts = productsResponse.data!.length;
        });
      }

      // Load revenue from API
      final revenueResponse = await OrderApiService.getRevenue();
      if (revenueResponse.success && revenueResponse.data != null) {
        // Update revenue if API provides more accurate data
        final apiRevenue = revenueResponse.data!['total_revenue'] ?? 0.0;
        if (apiRevenue > 0) {
          setState(() {
            _totalRevenue = apiRevenue.toDouble();
          });
        }
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

  Map<String, double> _calculateMonthlyRevenue(List<Order> orders) {
    final Map<String, double> monthlyRevenue = {};
    final now = DateTime.now();
    
    for (int i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month - i);
      final monthKey = '${month.month}/${month.year}';
      
      final monthOrders = orders.where((order) {
        final orderMonth = DateTime(order.createdAt.year, order.createdAt.month);
        return orderMonth.year == month.year && orderMonth.month == month.month && order.isDelivered;
      }).toList();
      
      monthlyRevenue[monthKey] = monthOrders.fold(0.0, (sum, order) => sum + order.totalPrice);
    }
    
    return monthlyRevenue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStatistics,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStatistics,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview Cards
                        Text(
                          'Tổng quan',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.3,
                          children: [
                            _buildStatCard(
                              context,
                              icon: Icons.shopping_bag,
                              title: 'Tổng đơn hàng',
                              value: _totalOrders.toString(),
                              color: Colors.blue,
                            ),
                            _buildStatCard(
                              context,
                              icon: Icons.attach_money,
                              title: 'Doanh thu',
                              value: '${(_totalRevenue / 1000000).toStringAsFixed(1)}M VNĐ',
                              color: Colors.green,
                            ),
                            _buildStatCard(
                              context,
                              icon: Icons.inventory_2,
                              title: 'Sản phẩm',
                              value: _totalProducts.toString(),
                              color: Colors.orange,
                            ),
                            _buildStatCard(
                              context,
                              icon: Icons.pending,
                              title: 'Chờ xử lý',
                              value: _pendingOrders.toString(),
                              color: Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Order Status Chart
                        Text(
                          'Thống kê trạng thái đơn hàng',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildOrderStatusChart(),
                        const SizedBox(height: 24),

                        // Monthly Revenue Chart
                        Text(
                          'Doanh thu theo tháng',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildMonthlyRevenueChart(),
                        const SizedBox(height: 24),

                        // Recent Orders
                        Text(
                          'Đơn hàng gần đây',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ..._recentOrders.map((order) => _buildRecentOrderCard(order)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusChart() {
    final total = _orderStatusStats.values.fold(0, (sum, count) => sum + count);
    if (total == 0) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text('Chưa có dữ liệu'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _orderStatusStats.entries.map((entry) {
          final percentage = total > 0 ? entry.value / total : 0.0;
          final statusText = _getStatusText(entry.key);
          final color = _getStatusColor(entry.key);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    statusText,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: MediaQuery.of(context).size.width * percentage * 0.3,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthlyRevenueChart() {
    if (_monthlyRevenue.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text('Chưa có dữ liệu'),
        ),
      );
    }

    final maxRevenue = _monthlyRevenue.values.fold(0.0, (max, value) => value > max ? value : max);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _monthlyRevenue.entries.map((entry) {
          final percentage = maxRevenue > 0 ? entry.value / maxRevenue : 0.0;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: MediaQuery.of(context).size.width * percentage * 0.3,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(entry.value / 1000000).toStringAsFixed(1)}M',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn hàng #${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  order.statusText,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(order.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                order.formattedPrice,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.paymentStatusText,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'processing': return Colors.purple;
      case 'shipped': return Colors.indigo;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}