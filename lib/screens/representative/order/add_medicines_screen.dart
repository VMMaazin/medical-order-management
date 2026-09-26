import 'package:flutter/material.dart';

import '../../../models/order_draft.dart';

class AddMedicinesScreen extends StatelessWidget {
  final OrderDraft orderDraft;

  const AddMedicinesScreen({
    super.key,
    required this.orderDraft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicines'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF0D9488).withAlpha(80),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Color(0xFF0D9488),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Step 2 of 2: Medicines Selection',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Placeholder Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withAlpha(128),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.medication_liquid_outlined,
                        size: 40,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Medicine selection will be implemented in the next stage.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The selected Doctor and Chemist have been successfully passed forward in memory. No order has been saved in Firestore.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Selected Consultation & Delivery Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Doctor Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: const Color(0xFF0D9488).withAlpha(100),
                  ),
                ),
                color: const Color(0xFF0D9488).withAlpha(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderDraft.doctorName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              orderDraft.doctorSpecialization,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF0F766E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Phone: ${orderDraft.doctorPhone}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF0D9488),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Chemist Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: const Color(0xFF0284C7).withAlpha(100),
                  ),
                ),
                color: const Color(0xFF0284C7).withAlpha(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.local_pharmacy_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderDraft.chemistName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              orderDraft.chemistAddress,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF0369A1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Phone: ${orderDraft.chemistPhone}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF0284C7),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
