import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../providers/order_provider.dart';
import 'admin_home_screen.dart';
import 'admin_management_screen.dart';
import 'orders/admin_orders_screen.dart';
import 'admin_profile_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  final AppUser user;

  const AdminDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  void _navigateToOrders([String? status]) {
    if (status != null) {
      ref.read(adminOrderStatusFilterProvider.notifier).setFilter(status);
    }
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      AdminHomeScreen(
        user: widget.user,
        onNavigateToOrders: _navigateToOrders,
      ),
      const AdminOrdersScreen(),
      const AdminManagementScreen(),
      AdminProfileScreen(user: widget.user),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_center_outlined),
            selectedIcon: Icon(Icons.business_center),
            label: 'Management',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
