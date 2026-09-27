import 'order.dart';
import 'order_statistics.dart';

/// Available pre-defined and custom date filtering options for reports.
enum ReportDateRangeType {
  allTime,
  today,
  last7Days,
  last30Days,
  thisMonth,
  custom,
}

/// Represents a selected report date range filter.
class ReportDateRange {
  final ReportDateRangeType type;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const ReportDateRange({
    required this.type,
    this.customStartDate,
    this.customEndDate,
  });

  const ReportDateRange.allTime()
      : type = ReportDateRangeType.allTime,
        customStartDate = null,
        customEndDate = null;

  const ReportDateRange.today()
      : type = ReportDateRangeType.today,
        customStartDate = null,
        customEndDate = null;

  const ReportDateRange.last7Days()
      : type = ReportDateRangeType.last7Days,
        customStartDate = null,
        customEndDate = null;

  const ReportDateRange.last30Days()
      : type = ReportDateRangeType.last30Days,
        customStartDate = null,
        customEndDate = null;

  const ReportDateRange.thisMonth()
      : type = ReportDateRangeType.thisMonth,
        customStartDate = null,
        customEndDate = null;

  const ReportDateRange.custom({
    required DateTime startDate,
    required DateTime endDate,
  })  : type = ReportDateRangeType.custom,
        customStartDate = startDate,
        customEndDate = endDate;

  String get label {
    switch (type) {
      case ReportDateRangeType.allTime:
        return 'All Time';
      case ReportDateRangeType.today:
        return 'Today';
      case ReportDateRangeType.last7Days:
        return 'Last 7 Days';
      case ReportDateRangeType.last30Days:
        return 'Last 30 Days';
      case ReportDateRangeType.thisMonth:
        return 'This Month';
      case ReportDateRangeType.custom:
        if (customStartDate != null && customEndDate != null) {
          final s = customStartDate!;
          final e = customEndDate!;
          return '${s.day}/${s.month}/${s.year} - ${e.day}/${e.month}/${e.year}';
        }
        return 'Custom Range';
    }
  }

  /// Evaluates whether a given [dateTime] falls within this date range.
  ///
  /// Uses [referenceNow] for relative date boundaries (defaults to DateTime.now()).
  /// Safe against null dates: null dates are only included in [ReportDateRangeType.allTime].
  bool matches(DateTime? dateTime, [DateTime? referenceNow]) {
    if (type == ReportDateRangeType.allTime) return true;
    if (dateTime == null) return false;

    final now = referenceNow ?? DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (type) {
      case ReportDateRangeType.allTime:
        return true;
      case ReportDateRangeType.today:
        return !dateTime.isBefore(startOfToday) && !dateTime.isAfter(endOfToday);
      case ReportDateRangeType.last7Days:
        final start7 = startOfToday.subtract(const Duration(days: 6));
        return !dateTime.isBefore(start7) && !dateTime.isAfter(endOfToday);
      case ReportDateRangeType.last30Days:
        final start30 = startOfToday.subtract(const Duration(days: 29));
        return !dateTime.isBefore(start30) && !dateTime.isAfter(endOfToday);
      case ReportDateRangeType.thisMonth:
        final startMonth = DateTime(now.year, now.month, 1);
        final nextMonth = now.month == 12
            ? DateTime(now.year + 1, 1, 1)
            : DateTime(now.year, now.month + 1, 1);
        final endMonth = nextMonth.subtract(const Duration(milliseconds: 1));
        return !dateTime.isBefore(startMonth) && !dateTime.isAfter(endMonth);
      case ReportDateRangeType.custom:
        if (customStartDate == null || customEndDate == null) return true;
        final start = DateTime(
          customStartDate!.year,
          customStartDate!.month,
          customStartDate!.day,
        );
        final end = DateTime(
          customEndDate!.year,
          customEndDate!.month,
          customEndDate!.day,
          23,
          59,
          59,
          999,
        );
        return !dateTime.isBefore(start) && !dateTime.isAfter(end);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDateRange &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          customStartDate == other.customStartDate &&
          customEndDate == other.customEndDate;

  @override
  int get hashCode =>
      type.hashCode ^ customStartDate.hashCode ^ customEndDate.hashCode;
}

/// Breakdown data for a single order status.
class StatusBreakdownItem {
  final String status;
  final int count;
  final double percentage;
  final double totalValue;

  const StatusBreakdownItem({
    required this.status,
    required this.count,
    required this.percentage,
    required this.totalValue,
  });
}

/// Aggregated order performance for an individual Medical Representative.
class RepReportItem {
  final String representativeId;
  final String representativeName;
  final String representativeEmail;
  final int orderCount;
  final double totalValue;

  const RepReportItem({
    required this.representativeId,
    required this.representativeName,
    required this.representativeEmail,
    required this.orderCount,
    required this.totalValue,
  });
}

/// Aggregated order performance for an individual medicine.
class MedicineReportItem {
  final String medicineId;
  final String medicineName;
  final String brand;
  final int totalQuantity;
  final int orderCount;
  final double totalValue;

  const MedicineReportItem({
    required this.medicineId,
    required this.medicineName,
    required this.brand,
    required this.totalQuantity,
    required this.orderCount,
    required this.totalValue,
  });
}

/// Aggregated order performance for an individual chemist.
class ChemistReportItem {
  final String chemistId;
  final String chemistName;
  final String chemistPhone;
  final String chemistAddress;
  final int orderCount;
  final double totalValue;

  const ChemistReportItem({
    required this.chemistId,
    required this.chemistName,
    required this.chemistPhone,
    required this.chemistAddress,
    required this.orderCount,
    required this.totalValue,
  });
}

/// Aggregated data point along a time trend (daily or monthly).
class TrendReportItem {
  final String key;
  final String label;
  final DateTime date;
  final int orderCount;
  final double totalValue;

  const TrendReportItem({
    required this.key,
    required this.label,
    required this.date,
    required this.orderCount,
    required this.totalValue,
  });
}

/// Complete aggregated report model generated for the selected date range.
class OrderReport {
  final ReportDateRange dateRange;
  final OrderStatistics statistics;
  final List<StatusBreakdownItem> statusBreakdown;
  final List<RepReportItem> representativeBreakdown;
  final List<MedicineReportItem> topMedicines;
  final List<ChemistReportItem> topChemists;
  final List<TrendReportItem> orderTrend;
  final List<OrderModel> filteredOrders;

  const OrderReport({
    required this.dateRange,
    required this.statistics,
    required this.statusBreakdown,
    required this.representativeBreakdown,
    required this.topMedicines,
    required this.topChemists,
    required this.orderTrend,
    required this.filteredOrders,
  });

  bool get isEmpty => statistics.totalOrders == 0;
}
