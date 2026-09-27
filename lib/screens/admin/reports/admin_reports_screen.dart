import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/order_report.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_report_provider.dart';
import '../../../utils/currency_formatter.dart';
import 'widgets/order_trend_chart.dart';
import 'widgets/status_donut_chart.dart';

/// Admin Reports & Analytics Screen.
///
/// Provides executive summary statistics, status breakdown, time trend,
/// representative rankings, top medicine volumes, and chemist distributions.
class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  bool _showAllMedicines = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        centerTitle: false,
      ),
      body: userProfileAsync.when(
        data: (profile) {
          // Security: Admin-only access guard
          if (profile != null && profile.role != 'admin') {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gpp_bad_outlined, size: 54, color: Colors.redAccent),
                    SizedBox(height: 12),
                    Text(
                      'Access Denied',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Only administrators have access to Reports & Analytics.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final reportAsync = ref.watch(orderReportProvider);

          return SafeArea(
            child: reportAsync.when(
              data: (report) => _buildReportContent(context, theme, report),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Error loading report: $err'),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error verifying authorization: $err'),
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent(
    BuildContext context,
    ThemeData theme,
    OrderReport report,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Date Range Filter Bar
          _buildDateRangeSelector(context, theme, report.dateRange),
          const SizedBox(height: 16),

          // Check if filtered dataset is empty
          if (report.isEmpty) ...[
            _buildEmptyStateCard(context, theme),
          ] else ...[
            // 2. Summary Cards
            _buildSummarySection(theme, report),
            const SizedBox(height: 20),

            // 3. Order Status Breakdown
            _buildStatusBreakdownSection(theme, report),
            const SizedBox(height: 20),

            // 4. Order Trend
            _buildOrderTrendSection(theme, report),
            const SizedBox(height: 20),

            // 5. Orders by Representative
            _buildRepresentativeSection(theme, report),
            const SizedBox(height: 20),

            // 6. Top Medicines
            _buildTopMedicinesSection(theme, report),
            const SizedBox(height: 20),

            // 7. Top Chemists
            _buildTopChemistsSection(theme, report),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(
    BuildContext context,
    ThemeData theme,
    ReportDateRange currentRange,
  ) {
    const options = [
      {'type': ReportDateRangeType.allTime, 'label': 'All Time'},
      {'type': ReportDateRangeType.today, 'label': 'Today'},
      {'type': ReportDateRangeType.last7Days, 'label': 'Last 7 Days'},
      {'type': ReportDateRangeType.last30Days, 'label': 'Last 30 Days'},
      {'type': ReportDateRangeType.thisMonth, 'label': 'This Month'},
      {'type': ReportDateRangeType.custom, 'label': 'Custom Range'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.date_range_outlined, size: 16, color: Color(0xFF0D9488)),
            const SizedBox(width: 6),
            Text(
              'DATE RANGE: ${currentRange.label.toUpperCase()}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                color: Color(0xFF0F766E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((opt) {
              final type = opt['type'] as ReportDateRangeType;
              final label = opt['label'] as String;
              final isSelected = currentRange.type == type;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0D9488).withAlpha(40),
                  checkmarkColor: const Color(0xFF0F766E),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF0F766E) : null,
                  ),
                  onSelected: (_) async {
                    if (type == ReportDateRangeType.custom) {
                      final now = DateTime.now();
                      final initialRange = currentRange.customStartDate != null &&
                              currentRange.customEndDate != null
                          ? DateTimeRange(
                              start: currentRange.customStartDate!,
                              end: currentRange.customEndDate!,
                            )
                          : DateTimeRange(
                              start: now.subtract(const Duration(days: 7)),
                              end: now,
                            );

                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDateRange: initialRange,
                        helpText: 'Select Custom Date Range',
                      );

                      if (picked != null) {
                        ref
                            .read(reportDateRangeProvider.notifier)
                            .setCustomRange(picked.start, picked.end);
                      }
                    } else {
                      ref
                          .read(reportDateRangeProvider.notifier)
                          .selectType(type);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_outlined,
              size: 40,
              color: Color(0xFF0D9488),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No orders found for this period.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try selecting "All Time" or adjusting the date range filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () {
              ref
                  .read(reportDateRangeProvider.notifier)
                  .selectType(ReportDateRangeType.allTime);
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('View All Time'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F766E),
              side: const BorderSide(color: Color(0xFF0F766E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(ThemeData theme, OrderReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('REPORT SUMMARY', Icons.insights_outlined),
        // Primary Top Cards: Total Orders & Total Value
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Orders',
                value: '${report.statistics.totalOrders}',
                subtitle: 'in selected range',
                icon: Icons.receipt_long_outlined,
                color: const Color(0xFF0D9488),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Total Value',
                value: formatCurrency(report.statistics.totalOrderValue),
                subtitle: 'gross amount',
                icon: Icons.payments_outlined,
                color: const Color(0xFF0284C7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Status Mini Cards Grid
        Row(
          children: [
            Expanded(
              child: _buildMiniStatusCard(
                'Pending',
                report.statistics.pendingOrders,
                const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStatusCard(
                'Confirmed',
                report.statistics.confirmedOrders,
                const Color(0xFF0284C7),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStatusCard(
                'Processing',
                report.statistics.processingOrders,
                const Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMiniStatusCard(
                'Delivered',
                report.statistics.deliveredOrders,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStatusCard(
                'Cancelled',
                report.statistics.cancelledOrders,
                const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: color.withAlpha(16),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatusCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdownSection(ThemeData theme, OrderReport report) {
    return _buildCardWrapper(
      theme: theme,
      title: 'Order Status Breakdown',
      icon: Icons.pie_chart_outline,
      child: StatusDonutChart(
        items: report.statusBreakdown,
        totalOrders: report.statistics.totalOrders,
      ),
    );
  }

  Widget _buildOrderTrendSection(ThemeData theme, OrderReport report) {
    return _buildCardWrapper(
      theme: theme,
      title: 'Order Trend',
      icon: Icons.trending_up,
      child: OrderTrendChart(items: report.orderTrend),
    );
  }

  Widget _buildRepresentativeSection(ThemeData theme, OrderReport report) {
    final reps = report.representativeBreakdown;

    return _buildCardWrapper(
      theme: theme,
      title: 'Orders by Representative',
      icon: Icons.badge_outlined,
      child: reps.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('No representative order data.'),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reps.length,
              separatorBuilder: (_, _) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final rep = reps[index];
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF0284C7).withAlpha(30),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rep.representativeName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (rep.representativeEmail.isNotEmpty)
                            Text(
                              rep.representativeEmail,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${rep.orderCount} ${rep.orderCount == 1 ? "order" : "orders"}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatCurrency(rep.totalValue),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildTopMedicinesSection(ThemeData theme, OrderReport report) {
    final allMedicines = report.topMedicines;
    final displayMedicines = _showAllMedicines
        ? allMedicines
        : allMedicines.take(10).toList();

    return _buildCardWrapper(
      theme: theme,
      title: 'Top Medicines',
      icon: Icons.medication_outlined,
      child: allMedicines.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('No medicine data in this period.'),
              ),
            )
          : Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayMedicines.length,
                  separatorBuilder: (_, _) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    final med = displayMedicines[index];
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFF0D9488).withAlpha(30),
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                med.medicineName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${med.brand.isNotEmpty ? "${med.brand} • " : ""}in ${med.orderCount} ${med.orderCount == 1 ? "order" : "orders"}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${med.totalQuantity} units',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatCurrency(med.totalValue),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                if (allMedicines.length > 10) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAllMedicines = !_showAllMedicines;
                      });
                    },
                    icon: Icon(
                      _showAllMedicines
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 18,
                    ),
                    label: Text(
                      _showAllMedicines
                          ? 'Show Top 10 Only'
                          : 'View All (${allMedicines.length}) Medicines',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildTopChemistsSection(ThemeData theme, OrderReport report) {
    final chemists = report.topChemists;

    return _buildCardWrapper(
      theme: theme,
      title: 'Top Chemists',
      icon: Icons.local_pharmacy_outlined,
      child: chemists.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('No chemist order data.'),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chemists.length,
              separatorBuilder: (_, _) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final chm = chemists[index];
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF7C3AED).withAlpha(30),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chm.chemistName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (chm.chemistAddress.isNotEmpty)
                            Text(
                              chm.chemistAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${chm.orderCount} ${chm.orderCount == 1 ? "order" : "orders"}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatCurrency(chm.totalValue),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildCardWrapper({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF0D9488)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0D9488)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF0F766E),
            ),
          ),
        ],
      ),
    );
  }
}
