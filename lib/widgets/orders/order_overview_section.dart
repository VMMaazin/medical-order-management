import 'package:flutter/material.dart';

import '../../models/order_statistics.dart';
import '../../utils/currency_formatter.dart';

/// Clean Material 3 Order Overview statistics section used in Admin and Representative dashboards.
class OrderOverviewSection extends StatelessWidget {
  final String title;
  final String valueLabel;
  final OrderStatistics statistics;
  final void Function(String status) onStatusTap;
  final VoidCallback? onValueTap;

  const OrderOverviewSection({
    super.key,
    required this.title,
    required this.valueLabel,
    required this.statistics,
    required this.onStatusTap,
    this.onValueTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 1: Total Orders & Pending
        Row(
          children: [
            Expanded(
              child: _OrderStatCard(
                label: 'Total Orders',
                count: statistics.totalOrders,
                icon: Icons.receipt_long_outlined,
                color: const Color(0xFF0F766E), // Teal
                onTap: () => onStatusTap('all'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OrderStatCard(
                label: 'Pending',
                count: statistics.pendingOrders,
                icon: Icons.hourglass_empty_rounded,
                color: const Color(0xFFD97706), // Amber
                onTap: () => onStatusTap('pending'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Confirmed & Processing
        Row(
          children: [
            Expanded(
              child: _OrderStatCard(
                label: 'Confirmed',
                count: statistics.confirmedOrders,
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF0284C7), // Blue
                onTap: () => onStatusTap('confirmed'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OrderStatCard(
                label: 'Processing',
                count: statistics.processingOrders,
                icon: Icons.sync_rounded,
                color: const Color(0xFF7C3AED), // Purple
                onTap: () => onStatusTap('processing'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 3: Delivered & Cancelled
        Row(
          children: [
            Expanded(
              child: _OrderStatCard(
                label: 'Delivered',
                count: statistics.deliveredOrders,
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFF10B981), // Emerald
                onTap: () => onStatusTap('delivered'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OrderStatCard(
                label: 'Cancelled',
                count: statistics.cancelledOrders,
                icon: Icons.cancel_outlined,
                color: const Color(0xFFEF4444), // Red
                onTap: () => onStatusTap('cancelled'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 4: Total Value Card
        _OrderTotalValueCard(
          label: valueLabel,
          amount: statistics.totalOrderValue,
          onTap: onValueTap ?? () => onStatusTap('all'),
        ),
      ],
    );
  }
}

class _OrderStatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OrderStatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(120),
        ),
      ),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderTotalValueCard extends StatelessWidget {
  final String label;
  final double amount;
  final VoidCallback onTap;

  const _OrderTotalValueCard({
    required this.label,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedAmount = formatCurrency(amount);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: const Color(0xFF0D9488).withAlpha(90),
        ),
      ),
      color: const Color(0xFF0D9488).withAlpha(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedAmount,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF0D9488),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
