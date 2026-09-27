import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../providers/order_provider.dart';
import 'representative_home_screen.dart';
import 'representative_orders_screen.dart';
import 'representative_profile_screen.dart';

class RepresentativeDashboardScreen extends ConsumerWidget {
  final AppUser user;

  const RepresentativeDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(representativeTabProvider);

    final screens = [
      RepresentativeHomeScreen(
        user: user,
        onNavigateToOrders: () {
          ref.read(representativeOrderStatusFilterProvider.notifier).reset();
          ref.read(representativeTabProvider.notifier).setTab(1);
        },
        onNavigateToOrdersWithFilter: (status) {
          if (status != null) {
            ref
                .read(representativeOrderStatusFilterProvider.notifier)
                .setFilter(status);
          }
          ref.read(representativeTabProvider.notifier).setTab(1);
        },
      ),
      const RepresentativeOrdersScreen(),
      RepresentativeProfileScreen(user: user),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(representativeTabProvider.notifier).setTab(index);
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

