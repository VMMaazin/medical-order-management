import 'package:flutter_test/flutter_test.dart';
import 'package:medical_order_management/data/medicine_catalog_data.dart';
import 'package:medical_order_management/models/order.dart';
import 'package:medical_order_management/models/order_item.dart';
import 'package:medical_order_management/models/order_report.dart';
import 'package:medical_order_management/models/order_statistics.dart';
import 'package:medical_order_management/services/order_report_service.dart';

void main() {
  group('Medicine Catalog Verification', () {
    test('Catalog contains exactly 165 unique medicines with valid metadata', () {
      expect(kOfficialMedicineCatalog.length, 165);

      final uniqueNames = <String>{};
      for (final item in kOfficialMedicineCatalog) {
        expect(item.name.trim().isNotEmpty, true, reason: 'Name must not be empty');
        expect(item.brand.trim().isNotEmpty, true, reason: 'Brand must not be empty');
        expect(item.category.trim().isNotEmpty, true, reason: 'Category must not be empty');
        expect(item.form.trim().isNotEmpty, true, reason: 'Dosage Form must not be empty');
        expect(item.strength.trim().isNotEmpty, true, reason: 'Strength must not be empty');
        expect(item.packSize.trim().isNotEmpty, true, reason: 'Pack size must not be empty');
        expect(item.mrp >= 0.0, true, reason: 'MRP must be non-negative');
        expect(item.ptr >= 0.0, true, reason: 'PTR must be non-negative');

        final lowerName = item.name.toLowerCase();
        expect(uniqueNames.contains(lowerName), false,
            reason: 'Duplicate medicine name found: ${item.name}');
        uniqueNames.add(lowerName);
      }
    });

    test('First and last medicines match CSV items', () {
      final first = kOfficialMedicineCatalog.first;
      expect(first.idNumber, 1);
      expect(first.name, 'Appecrush-Gold');
      expect(first.form, 'Syrup');
      expect(first.category, 'Appetite Stimulant / Nutritional');

      final last = kOfficialMedicineCatalog.last;
      expect(last.idNumber, 165);
      expect(last.name, 'Zymofab Drops');
      expect(last.form, 'Drops');
      expect(last.category, 'Digestive Enzyme');
    });

    test('Medicines with pricing have accurate MRP and PTR values', () {
      final bravoclav375 = kOfficialMedicineCatalog.firstWhere((m) => m.name == 'Bravoclav-375');
      expect(bravoclav375.mrp, 196.87);
      expect(bravoclav375.ptr, 150.0);
      expect(bravoclav375.strength, '250mg + 125mg');

      final wikicox90 = kOfficialMedicineCatalog.firstWhere((m) => m.name == 'Wikicox-90');
      expect(wikicox90.mrp, 206.25);
      expect(wikicox90.ptr, 157.14);
      expect(wikicox90.category, 'Analgesic / Anti-inflammatory');
    });
  });

  group('Order Deletion & Dynamic Revenue Deduction Tests', () {
    final order1 = OrderModel(
      id: 'ORD_001',
      orderNumber: 'ORD-20261006-0001',
      representative: {'id': 'rep_1', 'name': 'John Doe', 'email': 'john@test.com'},
      doctor: {'id': 'doc_1', 'name': 'Dr. Sharma'},
      chemist: {'id': 'chm_1', 'name': 'Health Pharmacy'},
      items: [
        const OrderItem(
          medicineId: 'med_1',
          medicineName: 'Bravoclav-375',
          brand: 'Incuity',
          composition: 'Amoxycillin Trihydrate 250mg + Potassium Clavulanate 125mg',
          variantId: 'var_1',
          form: 'Tablet',
          strength: '250mg + 125mg',
          packSize: '1x10 Tablets',
          mrp: 196.87,
          supplierPrice: 150.0,
          quantity: 2,
          itemTotal: 300.0,
        ),
      ],
      totalItems: 1,
      totalQuantity: 2,
      totalAmount: 300.0,
      status: 'delivered',
      createdAt: DateTime.now(),
    );

    final order2 = OrderModel(
      id: 'ORD_002',
      orderNumber: 'ORD-20261006-0002',
      representative: {'id': 'rep_1', 'name': 'John Doe', 'email': 'john@test.com'},
      doctor: {'id': 'doc_2', 'name': 'Dr. Verma'},
      chemist: {'id': 'chm_2', 'name': 'City Chemist'},
      items: [
        const OrderItem(
          medicineId: 'med_2',
          medicineName: 'Wikicox-90',
          brand: 'Incuity',
          composition: 'Etoricoxib 90mg',
          variantId: 'var_2',
          form: 'Tablet',
          strength: '90mg',
          packSize: '1x10 Tablets',
          mrp: 206.25,
          supplierPrice: 157.14,
          quantity: 4,
          itemTotal: 628.56,
        ),
      ],
      totalItems: 1,
      totalQuantity: 4,
      totalAmount: 628.56,
      status: 'processing',
      createdAt: DateTime.now(),
    );

    test('Deleting an order deducts its amount from OrderStatistics', () {
      final initialOrders = [order1, order2];
      final initialStats = OrderStatistics.fromOrders(initialOrders);

      expect(initialStats.totalOrders, 2);
      expect(initialStats.totalOrderValue, closeTo(928.56, 0.01));

      // Simulate deleting order2 (e.g. test order deletion)
      final remainingOrders = initialOrders.where((o) => o.id != order2.id).toList();
      final updatedStats = OrderStatistics.fromOrders(remainingOrders);

      expect(updatedStats.totalOrders, 1);
      expect(updatedStats.totalOrderValue, closeTo(300.0, 0.01));
      // Difference equals the deleted order amount exactly
      expect(initialStats.totalOrderValue - updatedStats.totalOrderValue, closeTo(order2.totalAmount, 0.01));
    });

    test('Deleting an order dynamically updates OrderReport metrics', () {
      final initialOrders = [order1, order2];
      final initialReport = OrderReportService.generateReport(
        orders: initialOrders,
        dateRange: const ReportDateRange.allTime(),
      );

      expect(initialReport.statistics.totalOrders, 2);
      expect(initialReport.statistics.totalOrderValue, closeTo(928.56, 0.01));

      // Delete order1
      final ordersAfterDelete = initialOrders.where((o) => o.id != order1.id).toList();
      final updatedReport = OrderReportService.generateReport(
        orders: ordersAfterDelete,
        dateRange: const ReportDateRange.allTime(),
      );

      expect(updatedReport.statistics.totalOrders, 1);
      expect(updatedReport.statistics.totalOrderValue, closeTo(628.56, 0.01));
      expect(updatedReport.topMedicines.any((m) => m.medicineName == 'Bravoclav-375'), false);
      expect(updatedReport.topMedicines.first.medicineName, 'Wikicox-90');
    });
  });
}
