import '../models/order.dart';
import '../models/order_report.dart';
import '../models/order_statistics.dart';

/// Calculation engine for Admin Reports & Analytics.
///
/// Aggregates order data entirely client-side from the already-loaded
/// Firestore orders stream without additional database read queries.
class OrderReportService {
  /// Generates a comprehensive [OrderReport] from the provided list of [orders]
  /// according to the specified [dateRange].
  static OrderReport generateReport({
    required List<OrderModel> orders,
    required ReportDateRange dateRange,
    DateTime? referenceNow,
  }) {
    // 1. Filter orders based on the immutable createdAt timestamp
    final filteredOrders = orders.where((order) {
      return dateRange.matches(order.createdAt, referenceNow);
    }).toList();

    // 2. Summary statistics reuse
    final statistics = OrderStatistics.fromOrders(filteredOrders);

    // 3. Status breakdown
    final statusBreakdown = _calculateStatusBreakdown(filteredOrders, statistics.totalOrders);

    // 4. Orders by Medical Representative
    final representativeBreakdown = _calculateRepresentativeBreakdown(filteredOrders);

    // 5. Orders by Medicine (Top Medicines)
    final topMedicines = _calculateMedicineBreakdown(filteredOrders);

    // 6. Orders by Chemist (Top Chemists)
    final topChemists = _calculateChemistBreakdown(filteredOrders);

    // 7. Order Trend (Daily or Monthly depending on range duration)
    final orderTrend = _calculateOrderTrend(filteredOrders, dateRange);

    return OrderReport(
      dateRange: dateRange,
      statistics: statistics,
      statusBreakdown: statusBreakdown,
      representativeBreakdown: representativeBreakdown,
      topMedicines: topMedicines,
      topChemists: topChemists,
      orderTrend: orderTrend,
      filteredOrders: filteredOrders,
    );
  }

  static List<StatusBreakdownItem> _calculateStatusBreakdown(
    List<OrderModel> orders,
    int totalOrders,
  ) {
    const statuses = ['pending', 'confirmed', 'processing', 'delivered', 'cancelled'];
    final counts = <String, int>{for (var s in statuses) s: 0};
    final values = <String, double>{for (var s in statuses) s: 0.0};

    for (final order in orders) {
      final s = order.status.toLowerCase();
      if (counts.containsKey(s)) {
        counts[s] = counts[s]! + 1;
        values[s] = values[s]! + order.totalAmount;
      } else {
        counts[s] = (counts[s] ?? 0) + 1;
        values[s] = (values[s] ?? 0.0) + order.totalAmount;
      }
    }

    return statuses.map((status) {
      final count = counts[status] ?? 0;
      final val = values[status] ?? 0.0;
      final percentage = totalOrders > 0 ? (count / totalOrders) * 100 : 0.0;
      return StatusBreakdownItem(
        status: status,
        count: count,
        percentage: percentage,
        totalValue: val,
      );
    }).toList();
  }

  static List<RepReportItem> _calculateRepresentativeBreakdown(List<OrderModel> orders) {
    final map = <String, _RepAccumulator>{};

    for (final order in orders) {
      final key = order.representativeId.isNotEmpty
          ? order.representativeId
          : (order.representativeName.isNotEmpty ? order.representativeName : 'unknown_rep');

      final acc = map.putIfAbsent(
        key,
        () => _RepAccumulator(
          representativeId: order.representativeId,
          representativeName: order.representativeName.isNotEmpty
              ? order.representativeName
              : 'Unknown Representative',
          representativeEmail: order.representativeEmail,
        ),
      );

      acc.orderCount += 1;
      acc.totalValue += order.totalAmount;
    }

    final list = map.values.map((a) {
      return RepReportItem(
        representativeId: a.representativeId,
        representativeName: a.representativeName,
        representativeEmail: a.representativeEmail,
        orderCount: a.orderCount,
        totalValue: a.totalValue,
      );
    }).toList();

    // Sort by order count descending; secondary sort by total value descending
    list.sort((a, b) {
      final cmp = b.orderCount.compareTo(a.orderCount);
      if (cmp != 0) return cmp;
      return b.totalValue.compareTo(a.totalValue);
    });

    return list;
  }

  static List<MedicineReportItem> _calculateMedicineBreakdown(List<OrderModel> orders) {
    final map = <String, _MedicineAccumulator>{};

    for (final order in orders) {
      final seenMedicinesInOrder = <String>{};

      for (final item in order.items) {
        final key = item.medicineId.isNotEmpty
            ? item.medicineId
            : (item.medicineName.isNotEmpty ? item.medicineName : 'unknown_med');

        final acc = map.putIfAbsent(
          key,
          () => _MedicineAccumulator(
            medicineId: item.medicineId,
            medicineName: item.medicineName.isNotEmpty ? item.medicineName : 'Unknown Medicine',
            brand: item.brand,
          ),
        );

        acc.totalQuantity += item.quantity;
        acc.totalValue += item.itemTotal;

        if (!seenMedicinesInOrder.contains(key)) {
          acc.orderCount += 1;
          seenMedicinesInOrder.add(key);
        }
      }
    }

    final list = map.values.map((a) {
      return MedicineReportItem(
        medicineId: a.medicineId,
        medicineName: a.medicineName,
        brand: a.brand,
        totalQuantity: a.totalQuantity,
        orderCount: a.orderCount,
        totalValue: a.totalValue,
      );
    }).toList();

    // Sort by total quantity ordered descending; secondary sort by total value descending
    list.sort((a, b) {
      final cmp = b.totalQuantity.compareTo(a.totalQuantity);
      if (cmp != 0) return cmp;
      return b.totalValue.compareTo(a.totalValue);
    });

    return list;
  }

  static List<ChemistReportItem> _calculateChemistBreakdown(List<OrderModel> orders) {
    final map = <String, _ChemistAccumulator>{};

    for (final order in orders) {
      final key = order.chemistId.isNotEmpty
          ? order.chemistId
          : (order.chemistName.isNotEmpty ? order.chemistName : 'unknown_chemist');

      final acc = map.putIfAbsent(
        key,
        () => _ChemistAccumulator(
          chemistId: order.chemistId,
          chemistName: order.chemistName.isNotEmpty ? order.chemistName : 'Unknown Chemist',
          chemistPhone: order.chemistPhone,
          chemistAddress: order.chemistAddress,
        ),
      );

      acc.orderCount += 1;
      acc.totalValue += order.totalAmount;
    }

    final list = map.values.map((a) {
      return ChemistReportItem(
        chemistId: a.chemistId,
        chemistName: a.chemistName,
        chemistPhone: a.chemistPhone,
        chemistAddress: a.chemistAddress,
        orderCount: a.orderCount,
        totalValue: a.totalValue,
      );
    }).toList();

    // Sort by total order value descending; secondary sort by order count descending
    list.sort((a, b) {
      final cmp = b.totalValue.compareTo(a.totalValue);
      if (cmp != 0) return cmp;
      return b.orderCount.compareTo(a.orderCount);
    });

    return list;
  }

  static List<TrendReportItem> _calculateOrderTrend(
    List<OrderModel> orders,
    ReportDateRange dateRange,
  ) {
    final isDaily = _isDailyTrend(dateRange);
    final map = <String, _TrendAccumulator>{};

    for (final order in orders) {
      if (order.createdAt == null) continue;
      final dt = order.createdAt!;

      if (isDaily) {
        final bucketDate = DateTime(dt.year, dt.month, dt.day);
        final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        final label = '${dt.day} ${_monthName(dt.month)}';

        final acc = map.putIfAbsent(
          key,
          () => _TrendAccumulator(key: key, label: label, date: bucketDate),
        );
        acc.orderCount += 1;
        acc.totalValue += order.totalAmount;
      } else {
        final bucketDate = DateTime(dt.year, dt.month, 1);
        final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
        final label = '${_monthName(dt.month)} ${dt.year}';

        final acc = map.putIfAbsent(
          key,
          () => _TrendAccumulator(key: key, label: label, date: bucketDate),
        );
        acc.orderCount += 1;
        acc.totalValue += order.totalAmount;
      }
    }

    final list = map.values.map((a) {
      return TrendReportItem(
        key: a.key,
        label: a.label,
        date: a.date,
        orderCount: a.orderCount,
        totalValue: a.totalValue,
      );
    }).toList();

    // Sort chronologically ascending
    list.sort((a, b) => a.date.compareTo(b.date));

    return list;
  }

  static bool _isDailyTrend(ReportDateRange dateRange) {
    switch (dateRange.type) {
      case ReportDateRangeType.today:
      case ReportDateRangeType.last7Days:
      case ReportDateRangeType.last30Days:
      case ReportDateRangeType.thisMonth:
        return true;
      case ReportDateRangeType.custom:
        if (dateRange.customStartDate != null && dateRange.customEndDate != null) {
          final diff = dateRange.customEndDate!.difference(dateRange.customStartDate!).inDays;
          return diff <= 31;
        }
        return true;
      case ReportDateRangeType.allTime:
        return false;
    }
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}

class _RepAccumulator {
  final String representativeId;
  final String representativeName;
  final String representativeEmail;
  int orderCount = 0;
  double totalValue = 0.0;

  _RepAccumulator({
    required this.representativeId,
    required this.representativeName,
    required this.representativeEmail,
  });
}

class _MedicineAccumulator {
  final String medicineId;
  final String medicineName;
  final String brand;
  int totalQuantity = 0;
  int orderCount = 0;
  double totalValue = 0.0;

  _MedicineAccumulator({
    required this.medicineId,
    required this.medicineName,
    required this.brand,
  });
}

class _ChemistAccumulator {
  final String chemistId;
  final String chemistName;
  final String chemistPhone;
  final String chemistAddress;
  int orderCount = 0;
  double totalValue = 0.0;

  _ChemistAccumulator({
    required this.chemistId,
    required this.chemistName,
    required this.chemistPhone,
    required this.chemistAddress,
  });
}

class _TrendAccumulator {
  final String key;
  final String label;
  final DateTime date;
  int orderCount = 0;
  double totalValue = 0.0;

  _TrendAccumulator({
    required this.key,
    required this.label,
    required this.date,
  });
}
