import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../models/order_statistics.dart';
import '../services/order_service.dart';
import 'auth_provider.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

class RepresentativeTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

final representativeTabProvider =
    NotifierProvider<RepresentativeTabNotifier, int>(
  RepresentativeTabNotifier.new,
);

final myOrdersStreamProvider =
    StreamProvider.autoDispose<List<OrderModel>>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) {
    return Stream.value([]);
  }

  final service = ref.watch(orderServiceProvider);
  return service.watchMyOrders(authUser.uid);
});

final singleOrderStreamProvider =
    StreamProvider.autoDispose.family<OrderModel?, String>((ref, orderId) {
  final service = ref.watch(orderServiceProvider);
  return service.watchOrder(orderId);
});

/// Stream all orders for admin
final allOrdersStreamProvider =
    StreamProvider.autoDispose<List<OrderModel>>((ref) {
  final service = ref.watch(orderServiceProvider);
  return service.watchAllOrders();
});

class AdminOrderSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final adminOrderSearchQueryProvider =
    NotifierProvider<AdminOrderSearchQueryNotifier, String>(
  AdminOrderSearchQueryNotifier.new,
);

class AdminOrderStatusFilterNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void setFilter(String status) => state = status.toLowerCase();
  void reset() => state = 'all';
}

final adminOrderStatusFilterProvider =
    NotifierProvider<AdminOrderStatusFilterNotifier, String>(
  AdminOrderStatusFilterNotifier.new,
);

/// Locally filtered orders by search query and status filter
final filteredAdminOrdersProvider =
    Provider.autoDispose<AsyncValue<List<OrderModel>>>((ref) {
  final ordersAsync = ref.watch(allOrdersStreamProvider);
  final query = ref.watch(adminOrderSearchQueryProvider).toLowerCase().trim();
  final statusFilter = ref.watch(adminOrderStatusFilterProvider);

  return ordersAsync.whenData((orders) {
    return orders.where((order) {
      // 1. Status Filter
      if (statusFilter != 'all') {
        if (order.status.toLowerCase() != statusFilter) {
          return false;
        }
      }

      // 2. Search Query (orderNumber, rep name, doc name, chemist name)
      if (query.isNotEmpty) {
        final matchesNumber =
            order.orderNumber.toLowerCase().contains(query);
        final matchesRep =
            order.representativeName.toLowerCase().contains(query);
        final matchesDoc =
            order.doctorName.toLowerCase().contains(query);
        final matchesChemist =
            order.chemistName.toLowerCase().contains(query);

        if (!matchesNumber &&
            !matchesRep &&
            !matchesDoc &&
            !matchesChemist) {
          return false;
        }
      }

      return true;
    }).toList();
  });
});

class RepresentativeOrderStatusFilterNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void setFilter(String status) => state = status.toLowerCase();
  void reset() => state = 'all';
}

final representativeOrderStatusFilterProvider =
    NotifierProvider<RepresentativeOrderStatusFilterNotifier, String>(
  RepresentativeOrderStatusFilterNotifier.new,
);

/// Locally filtered orders for representative by status filter
final filteredRepresentativeOrdersProvider =
    Provider.autoDispose<AsyncValue<List<OrderModel>>>((ref) {
  final ordersAsync = ref.watch(myOrdersStreamProvider);
  final statusFilter = ref.watch(representativeOrderStatusFilterProvider);

  return ordersAsync.whenData((orders) {
    if (statusFilter == 'all') {
      return orders;
    }
    return orders
        .where((order) => order.status.toLowerCase() == statusFilter)
        .toList();
  });
});

/// Real-time derived order statistics for admin across all orders
final adminOrderStatisticsProvider =
    Provider.autoDispose<AsyncValue<OrderStatistics>>((ref) {
  final ordersAsync = ref.watch(allOrdersStreamProvider);
  return ordersAsync.whenData((orders) => OrderStatistics.fromOrders(orders));
});

/// Real-time derived order statistics for medical representative (only their own orders)
final representativeOrderStatisticsProvider =
    Provider.autoDispose<AsyncValue<OrderStatistics>>((ref) {
  final ordersAsync = ref.watch(myOrdersStreamProvider);
  return ordersAsync.whenData((orders) => OrderStatistics.fromOrders(orders));
});
