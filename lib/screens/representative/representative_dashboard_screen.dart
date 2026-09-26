import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import 'representative_home_screen.dart';
import 'representative_orders_screen.dart';
import 'representative_profile_screen.dart';

class RepresentativeDashboardScreen extends StatefulWidget {
  final AppUser user;

  const RepresentativeDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<RepresentativeDashboardScreen> createState() =>
      _RepresentativeDashboardScreenState();
}

class _RepresentativeDashboardScreenState
    extends State<RepresentativeDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      RepresentativeHomeScreen(
        user: widget.user,
        onNavigateToOrders: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
      ),
      const RepresentativeOrdersScreen(),
      RepresentativeProfileScreen(user: widget.user),
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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
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
