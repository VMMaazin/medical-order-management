import 'order.dart';

/// Aggregated order statistics derived from a list of orders.
class OrderStatistics {
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int processingOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final double totalOrderValue;

  const OrderStatistics({
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.confirmedOrders = 0,
    this.processingOrders = 0,
    this.deliveredOrders = 0,
    this.cancelledOrders = 0,
    this.totalOrderValue = 0.0,
  });

  /// Computes order statistics by iterating through orders once.
  factory OrderStatistics.fromOrders(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return empty;
    }

    int pending = 0;
    int confirmed = 0;
    int processing = 0;
    int delivered = 0;
    int cancelled = 0;
    double totalVal = 0.0;

    for (final order in orders) {
      totalVal += order.totalAmount;
      switch (order.status.toLowerCase().trim()) {
        case 'pending':
          pending++;
          break;
        case 'confirmed':
          confirmed++;
          break;
        case 'processing':
          processing++;
          break;
        case 'delivered':
          delivered++;
          break;
        case 'cancelled':
          cancelled++;
          break;
      }
    }

    return OrderStatistics(
      totalOrders: orders.length,
      pendingOrders: pending,
      confirmedOrders: confirmed,
      processingOrders: processing,
      deliveredOrders: delivered,
      cancelledOrders: cancelled,
      totalOrderValue: totalVal,
    );
  }

  static const empty = OrderStatistics();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStatistics &&
          runtimeType == other.runtimeType &&
          totalOrders == other.totalOrders &&
          pendingOrders == other.pendingOrders &&
          confirmedOrders == other.confirmedOrders &&
          processingOrders == other.processingOrders &&
          deliveredOrders == other.deliveredOrders &&
          cancelledOrders == other.cancelledOrders &&
          totalOrderValue == other.totalOrderValue;

  @override
  int get hashCode => Object.hash(
        totalOrders,
        pendingOrders,
        confirmedOrders,
        processingOrders,
        deliveredOrders,
        cancelledOrders,
        totalOrderValue,
      );
}
