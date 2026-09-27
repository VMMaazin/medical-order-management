import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../models/order_report.dart';
import '../../../../utils/currency_formatter.dart';

/// Donut chart and breakdown list for order statuses.
class StatusDonutChart extends StatelessWidget {
  final List<StatusBreakdownItem> items;
  final int totalOrders;

  const StatusDonutChart({
    super.key,
    required this.items,
    required this.totalOrders,
  });

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF0284C7); // Blue
      case 'processing':
        return const Color(0xFF7C3AED); // Purple
      case 'delivered':
        return const Color(0xFF10B981); // Emerald Green
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      case 'pending':
      default:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Donut Chart Graphic
        SizedBox(
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(180, 180),
                painter: _DonutChartPainter(
                  items: items,
                  totalOrders: totalOrders,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$totalOrders',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F766E),
                    ),
                  ),
                  Text(
                    totalOrders == 1 ? 'Order' : 'Orders',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Legend / List of items
        Column(
          children: items.map((item) {
            final color = getStatusColor(item.status);
            final statusLabel =
                item.status[0].toUpperCase() + item.status.substring(1);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    '${item.count} (${item.percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: Text(
                      formatCurrency(item.totalValue),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<StatusBreakdownItem> items;
  final int totalOrders;
  final Color backgroundColor;

  _DonutChartPainter({
    required this.items,
    required this.totalOrders,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 24.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    if (totalOrders == 0) return;

    var startAngle = -math.pi / 2;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    for (final item in items) {
      if (item.count == 0) continue;
      final sweepAngle = (item.count / totalOrders) * 2 * math.pi;

      final paint = Paint()
        ..color = StatusDonutChart.getStatusColor(item.status)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.totalOrders != totalOrders ||
        oldDelegate.items != items ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
