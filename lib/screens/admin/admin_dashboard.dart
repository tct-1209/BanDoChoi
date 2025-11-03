import 'package:flutter/material.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_users_screen.dart';
import 'admin_statistics_screen.dart';
import 'admin_categories_screen.dart';
import '../../services/product_api_service.dart';
import '../../services/order_api_service.dart';
import '../../models/product.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  int _totalProducts = 0;
  int _totalCategories = 0;
  int _activeProducts = 0;
  int _totalOrders = 0;
  int _pendingOrders = 0;
  double _totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      // Load products
      final productsResponse = await ProductApiService.getAllProducts();
      if (productsResponse.success && productsResponse.data != null) {
        final products = productsResponse.data!;
        setState(() {
          _totalProducts = products.length;
          _activeProducts = products.where((p) => (p as Product).isActive).length;
        });
      }

      // Load categories
      final categoriesResponse = await CategoryApiService.getAllCategories();
      if (categoriesResponse.success && categoriesResponse.data != null) {
        setState(() {
          _totalCategories = categoriesResponse.data!.length;
        });
      }

      // Load orders
      final ordersResponse = await OrderApiService.getAllOrders();
      if (ordersResponse.success && ordersResponse.data != null) {
        final orders = ordersResponse.data!;
        setState(() {
          _totalOrders = orders.length;
          _pendingOrders = orders.where((o) => o.isPending).length;
          _totalRevenue = orders.where((o) => o.isPaid).fold(0.0, (sum, o) => sum + o.totalPrice);
        });
      }
    } catch (e) {
      // Handle error silently for dashboard
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quản lý',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bảng điều khiển quản trị viên',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              
              // Statistics Cards - Ẩn đi vì không có dữ liệu
              // if (!_isLoading) ...[
              //   Row(
              //     children: [
              //       Expanded(
              //         child: _buildStatCard(
              //           context,
              //           title: 'Tổng sản phẩm',
              //           value: _totalProducts.toString(),
              //           icon: Icons.inventory_2,
              //           color: Colors.blue,
              //         ),
              //       ),
              //       const SizedBox(width: 16),
              //       Expanded(
              //         child: _buildStatCard(
              //           context,
              //           title: 'Sản phẩm hoạt động',
              //           value: _activeProducts.toString(),
              //           icon: Icons.check_circle,
              //           color: Colors.green,
              //         ),
              //       ),
              //     ],
              //   ),
              //   const SizedBox(height: 16),
              //   Row(
              //     children: [
              //       Expanded(
              //         child: _buildStatCard(
              //           context,
              //           title: 'Danh mục',
              //           value: _totalCategories.toString(),
              //           icon: Icons.category,
              //           color: Colors.purple,
              //         ),
              //       ),
              //       const SizedBox(width: 16),
              //       Expanded(
              //         child: _buildStatCard(
              //           context,
              //           title: 'Đơn hàng hôm nay',
              //           value: _totalOrders.toString(),
              //           icon: Icons.shopping_cart,
              //           color: Colors.orange,
              //         ),
              //       ),
              //     ],
              //   ),
              //   const SizedBox(height: 24),
              // ],

              // Management Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    icon: Icons.inventory_2_outlined,
                    title: 'Sản phẩm',
                    subtitle: 'Quản lý sản phẩm',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminProductsScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.category_outlined,
                    title: 'Danh mục',
                    subtitle: 'Quản lý danh mục',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminCategoriesScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Đơn hàng',
                    subtitle: 'Quản lý đơn hàng',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminOrdersScreen()),
                      );
                    },
                  ),
                  // _buildDashboardCard(
                  //   context,
                  //   icon: Icons.people_outline,
                  //   title: 'Người dùng',
                  //   subtitle: 'Quản lý người dùng',
                  //   color: Colors.green,
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => const AdminUsersScreen()),
                  //     );
                  //   },
                  // ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Thống kê',
                    subtitle: 'Xem báo cáo',
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminStatisticsScreen()),
                      );
                    },
                  ),
                  // _buildDashboardCard(
                  //   context,
                  //   icon: Icons.settings,
                  //   title: 'Cài đặt',
                  //   subtitle: 'Cấu hình hệ thống',
                  //   color: Colors.grey,
                  //   onTap: () {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //         content: Text('Chức năng cài đặt sẽ được thêm vào sau'),
                  //         backgroundColor: Colors.orange,
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
