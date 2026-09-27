import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../models/order_report.dart';
import '../../../../utils/currency_formatter.dart';

/// Visual bar chart displaying order trends across daily or monthly intervals.
class OrderTrendChart extends StatelessWidget {
  final List<TrendReportItem> items;

  const OrderTrendChart({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: Text(
          'No trend activity to display.',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final maxCount = items.map((i) => i.orderCount).fold<int>(0, math.max);
    final effectiveMax = maxCount > 0 ? maxCount : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Peak Summary banner
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${items.length} ${items.length == 1 ? "Period" : "Periods"}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Peak: $maxCount ${maxCount == 1 ? "order" : "orders"}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F766E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Scrollable horizontal Bar Chart
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: items.map((item) {
              final ratio = item.orderCount / effectiveMax;
              final isPeak = item.orderCount == maxCount && maxCount > 0;
              final barHeight = 24.0 + (ratio * 90.0);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Order count on top of bar
                    Text(
                      '${item.orderCount}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPeak
                            ? const Color(0xFF0F766E)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Bar column with Tooltip
                    Tooltip(
                      message:
                          '${item.label}: ${item.orderCount} orders (${formatCurrency(item.totalValue)})',
                      child: Container(
                        width: 28,
                        height: barHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isPeak
                                ? [
                                    const Color(0xFF0F766E),
                                    const Color(0xFF14B8A6),
                                  ]
                                : [
                                    const Color(0xFF0284C7).withAlpha(180),
                                    const Color(0xFF38BDF8),
                                  ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Date label at bottom
                    SizedBox(
                      width: 48,
                      child: Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isPeak ? FontWeight.bold : FontWeight.normal,
                          color: isPeak
                              ? const Color(0xFF0F766E)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
