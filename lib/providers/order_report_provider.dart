import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_report.dart';
import '../services/order_report_service.dart';
import 'order_provider.dart';

/// Notifier managing the active date range filter for reports.
class ReportDateRangeNotifier extends Notifier<ReportDateRange> {
  @override
  ReportDateRange build() => const ReportDateRange.allTime();

  void selectType(ReportDateRangeType type) {
    switch (type) {
      case ReportDateRangeType.allTime:
        state = const ReportDateRange.allTime();
        break;
      case ReportDateRangeType.today:
        state = const ReportDateRange.today();
        break;
      case ReportDateRangeType.last7Days:
        state = const ReportDateRange.last7Days();
        break;
      case ReportDateRangeType.last30Days:
        state = const ReportDateRange.last30Days();
        break;
      case ReportDateRangeType.thisMonth:
        state = const ReportDateRange.thisMonth();
        break;
      case ReportDateRangeType.custom:
        // Keep existing custom dates if present, else default to today
        final now = DateTime.now();
        state = ReportDateRange.custom(
          startDate: state.customStartDate ?? now.subtract(const Duration(days: 7)),
          endDate: state.customEndDate ?? now,
        );
        break;
    }
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = ReportDateRange.custom(startDate: start, endDate: end);
  }
}

final reportDateRangeProvider =
    NotifierProvider<ReportDateRangeNotifier, ReportDateRange>(
  ReportDateRangeNotifier.new,
);

/// Computes the complete [OrderReport] derived from the global [allOrdersStreamProvider]
/// and filtered by [reportDateRangeProvider].
final orderReportProvider = Provider<AsyncValue<OrderReport>>((ref) {
  final ordersAsync = ref.watch(allOrdersStreamProvider);
  final dateRange = ref.watch(reportDateRangeProvider);

  return ordersAsync.whenData((orders) {
    return OrderReportService.generateReport(
      orders: orders,
      dateRange: dateRange,
    );
  });
});
