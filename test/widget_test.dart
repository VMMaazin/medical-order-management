import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_order_management/models/app_user.dart';
import 'package:medical_order_management/models/chemist.dart';
import 'package:medical_order_management/models/doctor.dart';
import 'package:medical_order_management/models/medical_rep.dart';
import 'package:medical_order_management/models/medicine.dart';
import 'package:medical_order_management/models/medicine_variant.dart';
import 'package:medical_order_management/models/order.dart';
import 'package:medical_order_management/models/order_draft.dart';
import 'package:medical_order_management/models/order_draft_item.dart';
import 'package:medical_order_management/models/order_item.dart';
import 'package:medical_order_management/models/order_statistics.dart';
import 'package:medical_order_management/providers/auth_provider.dart';
import 'package:medical_order_management/providers/chemist_provider.dart';
import 'package:medical_order_management/providers/doctor_provider.dart';
import 'package:medical_order_management/providers/medical_rep_provider.dart';
import 'package:medical_order_management/providers/medicine_provider.dart';
import 'package:medical_order_management/providers/order_provider.dart';
import 'package:medical_order_management/screens/admin/admin_dashboard_screen.dart';
import 'package:medical_order_management/screens/admin/admin_management_screen.dart';
import 'package:medical_order_management/screens/admin/admin_orders_screen.dart';
import 'package:medical_order_management/screens/admin/orders/admin_order_details_screen.dart';
import 'package:medical_order_management/screens/admin/admin_profile_screen.dart';
import 'package:medical_order_management/screens/admin/chemist/add_chemist_screen.dart';
import 'package:medical_order_management/screens/admin/chemist/chemist_details_screen.dart';
import 'package:medical_order_management/screens/admin/chemist/chemists_screen.dart';
import 'package:medical_order_management/screens/admin/doctor/add_doctor_screen.dart';
import 'package:medical_order_management/screens/admin/doctor/doctor_details_screen.dart';
import 'package:medical_order_management/screens/admin/doctor/doctors_screen.dart';
import 'package:medical_order_management/screens/admin/medical_rep/add_medical_rep_screen.dart';
import 'package:medical_order_management/screens/admin/medical_rep/medical_rep_details_screen.dart';
import 'package:medical_order_management/screens/admin/medical_rep/medical_reps_screen.dart';
import 'package:medical_order_management/screens/admin/medicine/add_medicine_screen.dart';
import 'package:medical_order_management/screens/admin/medicine/add_variant_dialog.dart';
import 'package:medical_order_management/screens/admin/medicine/medicine_details_screen.dart';
import 'package:medical_order_management/screens/admin/medicine/medicines_screen.dart';
import 'package:medical_order_management/screens/auth/auth_wrapper.dart';
import 'package:medical_order_management/screens/auth/login_screen.dart';
import 'package:medical_order_management/screens/representative/order/add_medicines_screen.dart';
import 'package:medical_order_management/screens/representative/order/create_order_screen.dart';
import 'package:medical_order_management/screens/representative/order/order_success_screen.dart';
import 'package:medical_order_management/screens/representative/order/representative_order_details_screen.dart';
import 'package:medical_order_management/screens/representative/order/review_order_screen.dart';
import 'package:medical_order_management/screens/representative/representative_dashboard_screen.dart';
import 'package:medical_order_management/screens/representative/representative_orders_screen.dart';
import 'package:medical_order_management/services/order_service.dart';
import 'package:medical_order_management/services/order_pdf_service.dart';
import 'package:medical_order_management/config/company_config.dart';
import 'package:medical_order_management/utils/currency_formatter.dart';
import 'package:medical_order_management/models/order_report.dart';
import 'package:medical_order_management/services/order_report_service.dart';
import 'package:medical_order_management/screens/admin/reports/admin_reports_screen.dart';
import 'package:medical_order_management/widgets/orders/order_overview_section.dart';

void main() {
  group('Doctor Model Tests', () {
    test('Doctor serialization and deserialization', () {
      final now = DateTime.now();
      final doctor = Doctor(
        id: 'DOC001',
        name: 'Dr. Rajesh Kumar',
        specialization: 'Cardiologist',
        phone: '+919876543210',
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = doctor.toMap();
      expect(map['name'], 'Dr. Rajesh Kumar');
      expect(map['specialization'], 'Cardiologist');
      expect(map['phone'], '+919876543210');
      expect(map['active'], true);

      final reconstructed = Doctor.fromFirestore(map, 'DOC001');
      expect(reconstructed.id, 'DOC001');
      expect(reconstructed.name, 'Dr. Rajesh Kumar');
      expect(reconstructed.specialization, 'Cardiologist');
      expect(reconstructed.phone, '+919876543210');
      expect(reconstructed.active, true);
    });
  });

  group('Chemist Model Tests', () {
    test('Chemist serialization and deserialization', () {
      final now = DateTime.now();
      final chemist = Chemist(
        id: 'CHM001',
        name: 'Apollo Pharmacy',
        phone: '+919876543210',
        address: '123 Main Road, Bangalore',
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = chemist.toMap();
      expect(map['name'], 'Apollo Pharmacy');
      expect(map['phone'], '+919876543210');
      expect(map['address'], '123 Main Road, Bangalore');
      expect(map['active'], true);

      final reconstructed = Chemist.fromFirestore(map, 'CHM001');
      expect(reconstructed.id, 'CHM001');
      expect(reconstructed.name, 'Apollo Pharmacy');
      expect(reconstructed.phone, '+919876543210');
      expect(reconstructed.address, '123 Main Road, Bangalore');
      expect(reconstructed.active, true);
    });
  });

  group('Medical Representative Model Tests', () {
    test('MedicalRep serialization and deserialization', () {
      final now = DateTime.now();
      final rep = MedicalRep(
        id: 'REP001',
        name: 'Rahul Sharma',
        email: 'rahul.sharma@med.com',
        phone: '+919876543210',
        role: 'medical_rep',
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = rep.toMap();
      expect(map['name'], 'Rahul Sharma');
      expect(map['email'], 'rahul.sharma@med.com');
      expect(map['phone'], '+919876543210');
      expect(map['role'], 'medical_rep');
      expect(map['active'], true);

      final reconstructed = MedicalRep.fromFirestore(map, 'REP001');
      expect(reconstructed.id, 'REP001');
      expect(reconstructed.name, 'Rahul Sharma');
      expect(reconstructed.email, 'rahul.sharma@med.com');
      expect(reconstructed.phone, '+919876543210');
      expect(reconstructed.role, 'medical_rep');
      expect(reconstructed.active, true);
    });
  });

  group('Medicine Model Tests', () {
    test('Medicine serialization and deserialization', () {
      final now = DateTime.now();
      final medicine = Medicine(
        id: 'MED001',
        name: 'Azithromycin',
        brand: 'ABC Pharma',
        composition: 'Azithromycin IP',
        category: 'Antibiotic',
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = medicine.toMap();
      expect(map['name'], 'Azithromycin');
      expect(map['brand'], 'ABC Pharma');
      expect(map['composition'], 'Azithromycin IP');
      expect(map['category'], 'Antibiotic');
      expect(map['active'], true);

      final reconstructed = Medicine.fromFirestore(map, 'MED001');
      expect(reconstructed.id, 'MED001');
      expect(reconstructed.name, 'Azithromycin');
      expect(reconstructed.brand, 'ABC Pharma');
      expect(reconstructed.active, true);
    });

    test('MedicineVariant serialization and numeric price validation', () {
      final variant = MedicineVariant(
        id: 'VAR001',
        medicineId: 'MED001',
        form: 'Tablet',
        strength: '500 mg',
        packSize: '10 tablets',
        mrp: 120.0,
        supplierPrice: 90.0,
        active: true,
      );

      final map = variant.toMap();
      expect(map['medicineId'], 'MED001');
      expect(map['form'], 'Tablet');
      expect(map['mrp'], 120.0);
      expect(map['supplierPrice'], 90.0);

      final reconstructed = MedicineVariant.fromFirestore(map, 'VAR001');
      expect(reconstructed.id, 'VAR001');
      expect(reconstructed.mrp, 120.0);
      expect(reconstructed.supplierPrice, 90.0);
    });
  });

  group('LoginScreen Tests', () {
    testWidgets('renders title, email, password fields and login button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('Medical Order Management'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('validates invalid email format',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid-email-address',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });
  });

  group('Admin Dashboard & Navigation Tests', () {
    const adminUser = AppUser(
      uid: 'admin_123',
      name: 'Syed Qizar',
      email: 'admin@medicalorder.com',
      role: 'admin',
      phone: '+919876543210',
      active: true,
    );

    testWidgets('renders greeting with user name and module cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardScreen(user: adminUser),
          ),
        ),
      );

      // App title and greeting
      expect(find.text('Medical Order Management'), findsOneWidget);
      expect(find.text('Welcome, Syed Qizar'), findsOneWidget);

      // Navigation Bar tabs
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Management'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Section cards (Note: 'Orders' appears both on card and navigation bar)
      expect(find.text('Orders'), findsNWidgets(2));
      expect(find.text('Medicines'), findsOneWidget);
      expect(find.text('Manage medicines and variants'), findsOneWidget);
      expect(find.text('Doctors'), findsOneWidget);
      expect(find.text('Manage doctors'), findsOneWidget);
      expect(find.text('Chemists'), findsOneWidget);
      expect(find.text('Manage chemist shops'), findsOneWidget);
      expect(find.text('Representatives'), findsOneWidget);
      expect(find.text('Manage representatives'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('View business/order reports'), findsOneWidget);
    });

    testWidgets('tapping Medicines card navigates to real MedicinesScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            medicinesStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(user: adminUser),
          ),
        ),
      );

      await tester.tap(find.text('Medicines'));
      await tester.pumpAndSettle();

      expect(find.byType(MedicinesScreen), findsOneWidget);
      expect(find.text('Search medicines...'), findsOneWidget);
      expect(find.text('Add Medicine'), findsNWidgets(2)); // FAB and empty state button
    });

    testWidgets('tapping Doctors card navigates to real DoctorsScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(user: adminUser),
          ),
        ),
      );

      await tester.tap(find.text('Doctors'));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorsScreen), findsOneWidget);
      expect(find.text('Search doctors...'), findsOneWidget);
      expect(find.text('Add Doctor'), findsNWidgets(2)); // FAB and empty state button
    });

    testWidgets('tapping Chemists card navigates to real ChemistsScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chemistsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(user: adminUser),
          ),
        ),
      );

      await tester.tap(find.text('Chemists'));
      await tester.pumpAndSettle();

      expect(find.byType(ChemistsScreen), findsOneWidget);
      expect(find.text('Search chemists...'), findsOneWidget);
      expect(find.text('Add Chemist'), findsNWidgets(2)); // FAB and empty state button
    });

    testWidgets('tapping Representatives card navigates to real MedicalRepsScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            medicalRepsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(user: adminUser),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Representatives'));
      await tester.tap(find.text('Representatives'));
      await tester.pumpAndSettle();

      expect(find.byType(MedicalRepsScreen), findsOneWidget);
      expect(find.text('Search representatives...'), findsOneWidget);
      expect(find.text('Add Representative'), findsNWidgets(2)); // FAB and empty state button
    });

    testWidgets('tapping Reports card navigates to real AdminReportsScreen',
        (WidgetTester tester) async {
      final fakeOrderService = _FakeOrderService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
            userProfileProvider.overrideWith((ref) => Stream.value(adminUser)),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(user: adminUser),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Reports'));
      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminReportsScreen), findsOneWidget);
      expect(find.text('Reports & Analytics'), findsOneWidget);
    });

    testWidgets('bottom navigation switches between tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardScreen(user: adminUser),
          ),
        ),
      );

      // Switch to Orders tab via navigation bar
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Orders'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdminOrdersScreen), findsOneWidget);
      expect(find.text('Orders Management'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Switch to Management tab via navigation bar
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Management'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdminManagementScreen), findsOneWidget);
      expect(find.text('Master Directory'), findsOneWidget);

      // Switch to Profile tab via navigation bar
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Profile'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdminProfileScreen), findsOneWidget);
      expect(find.text('Syed Qizar'), findsNWidgets(2));
      expect(find.text('admin@medicalorder.com'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });
  });

  group('Medicine Management Screens Tests', () {
    testWidgets('MedicinesScreen renders list of medicines with search filter',
        (WidgetTester tester) async {
      const med1 = Medicine(
        id: 'MED1',
        name: 'Azithromycin',
        brand: 'ABC Pharma',
        composition: 'Azithromycin IP',
        category: 'Antibiotic',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            medicinesStreamProvider.overrideWith((ref) => Stream.value([med1])),
            medicineActiveVariantCountProvider('MED1')
                .overrideWith((ref) => Stream.value(3)),
          ],
          child: const MaterialApp(
            home: MedicinesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Azithromycin'), findsOneWidget);
      expect(find.text('ABC Pharma'), findsOneWidget);
      expect(find.text('Azithromycin IP'), findsOneWidget);
      expect(find.text('Antibiotic'), findsOneWidget);
      expect(find.text('3 variants'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('AddMedicineScreen validates only medicine name as required parent field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddMedicineScreen(),
          ),
        ),
      );

      // Switch off initial variant to test parent medicine required fields
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Create Medicine');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Please enter medicine name'), findsOneWidget);
      expect(find.text('Please enter brand/manufacturer name'), findsNothing);
      expect(find.text('Please enter active composition'), findsNothing);
      expect(find.text('Please enter therapeutic category'), findsNothing);
    });

    testWidgets('MedicineDetailsScreen displays medicine info and variants list',
        (WidgetTester tester) async {
      const med = Medicine(
        id: 'MED1',
        name: 'Paracetamol',
        brand: 'HealthCorp',
        composition: 'Paracetamol 650mg',
        category: 'Analgesic',
        active: true,
      );

      const variant = MedicineVariant(
        id: 'VAR1',
        medicineId: 'MED1',
        form: 'Tablet',
        strength: '650 mg',
        packSize: '15 tablets',
        mrp: 35.0,
        supplierPrice: 24.0,
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            singleMedicineProvider('MED1').overrideWith((ref) => Stream.value(med)),
            medicineVariantsProvider('MED1')
                .overrideWith((ref) => Stream.value([variant])),
          ],
          child: const MaterialApp(
            home: MedicineDetailsScreen(medicineId: 'MED1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Paracetamol'), findsOneWidget);
      expect(find.text('HealthCorp'), findsOneWidget);
      expect(find.text('Variants'), findsOneWidget);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('650 mg'), findsOneWidget);
      expect(find.text('Pack Size: 15 tablets'), findsOneWidget);
      expect(find.text('₹35.00'), findsOneWidget);
      expect(find.text('₹24.00'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Deactivate'), findsNWidgets(2)); // Medicine and variant
    });

    testWidgets('AddVariantDialog validates price constraints',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AddVariantDialog(medicineId: 'MED1'),
            ),
          ),
        ),
      );

      // Enter higher supplier price than MRP
      await tester.enterText(
        find.widgetWithText(TextFormField, 'MRP (₹) *'),
        '50',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Supplier Price (₹) *'),
        '80',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Variant'));
      await tester.pumpAndSettle();

      expect(find.text('Cannot exceed MRP'), findsOneWidget);
    });
  });

  group('Doctor Management Screens Tests', () {
    testWidgets('DoctorsScreen renders doctor list with active status',
        (WidgetTester tester) async {
      const doc = Doctor(
        id: 'DOC1',
        name: 'Dr. Rajesh Kumar',
        specialization: 'Cardiologist',
        phone: '+919876543210',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorsStreamProvider.overrideWith((ref) => Stream.value([doc])),
          ],
          child: const MaterialApp(
            home: DoctorsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dr. Rajesh Kumar'), findsOneWidget);
      expect(find.text('Cardiologist'), findsOneWidget);
      expect(find.text('+919876543210'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('AddDoctorScreen validates required fields and phone format',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddDoctorScreen(),
          ),
        ),
      );

      // Try submitting empty form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Doctor'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter doctor name'), findsOneWidget);
      expect(find.text('Please enter doctor specialization'), findsNothing);

      // Enter invalid phone number
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Doctor Name *'),
        'Dr. Test',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Specialization (Optional)'),
        'Dentist',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number (Optional)'),
        '12345',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Doctor'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter a valid 10-digit Indian phone number'),
        findsOneWidget,
      );

      // Clear name so form does not submit to remote service
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Doctor Name *'),
        '',
      );

      // Enter valid 10-digit phone number
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number (Optional)'),
        '9876543210',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Doctor'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter a valid 10-digit Indian phone number'),
        findsNothing,
      );
      expect(find.text('Please enter doctor name'), findsOneWidget);
    });

    testWidgets('DoctorDetailsScreen displays doctor details and deactivation option',
        (WidgetTester tester) async {
      const doc = Doctor(
        id: 'DOC1',
        name: 'Dr. Priya Sharma',
        specialization: 'Dermatologist',
        phone: '+919876543211',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            singleDoctorProvider('DOC1').overrideWith((ref) => Stream.value(doc)),
          ],
          child: const MaterialApp(
            home: DoctorDetailsScreen(doctorId: 'DOC1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dr. Priya Sharma'), findsOneWidget);
      expect(find.text('Dermatologist'), findsOneWidget);
      expect(find.text('+919876543211'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Deactivate'), findsOneWidget);
    });
  });

  group('Chemist Management Screens Tests', () {
    testWidgets('ChemistsScreen renders chemist list with active status and details',
        (WidgetTester tester) async {
      const chm = Chemist(
        id: 'CHM1',
        name: 'Apollo Pharmacy',
        phone: '+919876543210',
        address: '123 MG Road, Bangalore',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chemistsStreamProvider.overrideWith((ref) => Stream.value([chm])),
          ],
          child: const MaterialApp(
            home: ChemistsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Apollo Pharmacy'), findsOneWidget);
      expect(find.text('+919876543210'), findsOneWidget);
      expect(find.text('123 MG Road, Bangalore'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('AddChemistScreen validates required fields and Indian phone format',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddChemistScreen(),
          ),
        ),
      );

      // Try submitting empty form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Chemist'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter chemist/shop name'), findsOneWidget);
      expect(find.text('Please enter phone number'), findsNothing);
      expect(find.text('Please enter address'), findsNothing);

      // Enter invalid phone number
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Chemist / Shop Name *'),
        'Apollo Pharmacy',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Address (Optional)'),
        '123 MG Road',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number (Optional)'),
        '12345',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Chemist'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter a valid 10-digit Indian phone number'),
        findsOneWidget,
      );

      // Clear name so form does not submit to remote service
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Chemist / Shop Name *'),
        '',
      );

      // Enter valid 10-digit phone number
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number (Optional)'),
        '9876543210',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Chemist'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter a valid 10-digit Indian phone number'),
        findsNothing,
      );
      expect(find.text('Please enter chemist/shop name'), findsOneWidget);
    });

    testWidgets('ChemistDetailsScreen displays chemist details and deactivation option',
        (WidgetTester tester) async {
      const chm = Chemist(
        id: 'CHM1',
        name: 'MedPlus Pharmacy',
        phone: '+919876543212',
        address: '456 Brigade Road, Bangalore',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            singleChemistProvider('CHM1').overrideWith((ref) => Stream.value(chm)),
          ],
          child: const MaterialApp(
            home: ChemistDetailsScreen(chemistId: 'CHM1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('MedPlus Pharmacy'), findsOneWidget);
      expect(find.text('+919876543212'), findsOneWidget);
      expect(find.text('456 Brigade Road, Bangalore'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Deactivate'), findsOneWidget);
    });
  });

  group('Medical Representative Management Screens Tests', () {
    testWidgets('MedicalRepsScreen renders representative list with active status and details',
        (WidgetTester tester) async {
      const rep = MedicalRep(
        id: 'REP1',
        name: 'Rahul Sharma',
        email: 'rahul.sharma@med.com',
        phone: '+919876543210',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            medicalRepsStreamProvider.overrideWith((ref) => Stream.value([rep])),
          ],
          child: const MaterialApp(
            home: MedicalRepsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Rahul Sharma'), findsOneWidget);
      expect(find.text('rahul.sharma@med.com'), findsOneWidget);
      expect(find.text('+919876543210'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('AddMedicalRepScreen validates required fields, email format, and Indian phone format',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddMedicalRepScreen(),
          ),
        ),
      );

      // Try submitting empty form
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Representative'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Representative'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter representative name'), findsOneWidget);
      expect(find.text('Please enter email address'), findsOneWidget);
      expect(find.text('Please enter phone number'), findsOneWidget);
      expect(find.text('Please enter temporary password'), findsOneWidget);

      // Verify temporary password info note
      expect(
        find.text(
          'This password is temporary. The representative should change it after receiving their login credentials.',
        ),
        findsOneWidget,
      );

      // Enter invalid email, invalid phone, and weak password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name *'),
        'Rahul Sharma',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address *'),
        'invalid-email',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number *'),
        '12345',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Temporary Password *'),
        'short',
      );

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Representative'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Representative'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(
        find.text('Please enter a valid 10-digit Indian phone number'),
        findsOneWidget,
      );
      expect(find.text('Password must be at least 8 characters'), findsOneWidget);

      // Toggle password visibility
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Clear name so form does not submit to remote service
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name *'),
        '',
      );

      // Enter valid email, valid phone, and valid password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address *'),
        'valid.rep@med.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number *'),
        '9876543210',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Temporary Password *'),
        'SecurePassword123',
      );

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Representative'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Representative'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsNothing);
      expect(
        find.text('Please enter a valid 10-digit Indian phone number'),
        findsNothing,
      );
      expect(find.text('Password must be at least 8 characters'), findsNothing);
      expect(find.text('Please enter representative name'), findsOneWidget);
    });

    testWidgets('AddMedicalRepScreen in Edit mode does not display password field',
        (WidgetTester tester) async {
      const rep = MedicalRep(
        id: 'REP1',
        name: 'Rahul Sharma',
        email: 'rahul.sharma@med.com',
        phone: '+919876543210',
        active: true,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddMedicalRepScreen(initialRep: rep),
          ),
        ),
      );

      expect(find.text('Edit Representative'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Temporary Password *'), findsNothing);
      expect(find.widgetWithText(TextFormField, 'Full Name *'), findsOneWidget);
    });

    testWidgets('MedicalRepDetailsScreen displays representative details and deactivation option',
        (WidgetTester tester) async {
      const rep = MedicalRep(
        id: 'REP1',
        name: 'Pooja Verma',
        email: 'pooja.verma@med.com',
        phone: '+919876543219',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            singleMedicalRepProvider('REP1').overrideWith((ref) => Stream.value(rep)),
          ],
          child: const MaterialApp(
            home: MedicalRepDetailsScreen(repId: 'REP1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Pooja Verma'), findsOneWidget);
      expect(find.text('pooja.verma@med.com'), findsOneWidget);
      expect(find.text('+919876543219'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Firebase Auth Account Linked'), findsOneWidget);
      expect(find.text('UID: REP1'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Deactivate'), findsOneWidget);
    });
  });

  group('Representative Dashboard Tests', () {
    const repUser = AppUser(
      uid: 'rep_123',
      name: 'John Representative',
      email: 'rep@medicalorder.com',
      role: 'medical_rep',
      phone: '+919876543211',
      active: true,
    );

    testWidgets('RepresentativeDashboardScreen renders Home tab with welcome, action cards, and metrics',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RepresentativeDashboardScreen(user: repUser),
          ),
        ),
      );

      // Welcome banner & identity
      expect(find.text('Medical Representative'), findsNWidgets(2)); // AppBar & banner badge
      expect(find.text('Welcome, John Representative'), findsOneWidget);

      // Actions
      expect(find.text('Create New Order'), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);

      // Metric placeholders
      expect(find.text("Today's Orders"), findsOneWidget);
      expect(find.text('Active Network'), findsOneWidget);
      expect(find.text('Pending Delivery'), findsOneWidget);

      // Tapping Create New Order opens CreateOrderScreen
      await tester.tap(find.text('Create New Order'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateOrderScreen), findsOneWidget);
      expect(find.text('Step 1 of 2'), findsOneWidget);
      expect(find.text('Doctor & Chemist'), findsOneWidget);
    });

    testWidgets('bottom navigation switches between Home, Orders, and Profile tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RepresentativeDashboardScreen(user: repUser),
          ),
        ),
      );

      // Initially on Home tab
      expect(find.text('Create New Order'), findsOneWidget);

      // Switch to Orders tab
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Orders'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('No orders yet.'), findsOneWidget);

      // Switch to Profile tab
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Profile'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account Information'), findsOneWidget);
      expect(find.text('John Representative'), findsNWidgets(2)); // Header & row
      expect(find.text('rep@medicalorder.com'), findsOneWidget);
      expect(find.text('+919876543211'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('My Orders card in Home tab navigates to Orders tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RepresentativeDashboardScreen(user: repUser),
          ),
        ),
      );

      // Tap 'My Orders' card
      await tester.tap(find.widgetWithText(Card, 'My Orders'));
      await tester.pumpAndSettle();

      expect(find.text('No orders yet.'), findsOneWidget);
    });
  });

  group('AuthWrapper Routing Tests', () {
    testWidgets('shows LoginScreen when unauthenticated',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(
            home: AuthWrapper(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Medical Order Management'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('shows inactive error screen if user active is false',
        (WidgetTester tester) async {
      final mockAuthUser = _MockUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockAuthUser)),
            userProfileProvider.overrideWith(
              (ref) => Stream.value(
                const AppUser(
                  uid: 'mock_uid',
                  name: 'Inactive User',
                  email: 'inactive@med.com',
                  role: 'medical_rep',
                  phone: '1234567890',
                  active: false,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: AuthWrapper(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Your account is inactive. Please contact the administrator.'),
        findsOneWidget,
      );
      expect(find.text('Back to Login'), findsOneWidget);
    });

    testWidgets('shows profile not found error if profile is null',
        (WidgetTester tester) async {
      final mockAuthUser = _MockUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockAuthUser)),
            userProfileProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(
            home: AuthWrapper(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('User profile not found. Please contact the administrator.'),
        findsOneWidget,
      );
      expect(find.text('Back to Login'), findsOneWidget);
    });

    testWidgets('routes to AdminDashboardScreen when role is admin',
        (WidgetTester tester) async {
      final mockAuthUser = _MockUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockAuthUser)),
            userProfileProvider.overrideWith(
              (ref) => Stream.value(
                const AppUser(
                  uid: 'mock_uid',
                  name: 'Syed Qizar',
                  email: 'syed@med.com',
                  role: 'admin',
                  phone: '1234567890',
                  active: true,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: AuthWrapper(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AdminDashboardScreen), findsOneWidget);
      expect(find.text('Welcome, Syed Qizar'), findsOneWidget);
    });

    testWidgets('routes to RepresentativeDashboardScreen when role is medical_rep',
        (WidgetTester tester) async {
      final mockAuthUser = _MockUser();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockAuthUser)),
            userProfileProvider.overrideWith(
              (ref) => Stream.value(
                const AppUser(
                  uid: 'mock_uid',
                  name: 'Rep Bob',
                  email: 'bob@med.com',
                  role: 'medical_rep',
                  phone: '1234567890',
                  active: true,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: AuthWrapper(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(RepresentativeDashboardScreen), findsOneWidget);
      expect(find.text('Medical Representative'), findsNWidgets(2));
      expect(find.text('Welcome, Rep Bob'), findsOneWidget);
    });
  });

  group('Order Creation Flow Tests', () {
    const activeDoc1 = Doctor(
      id: 'DOC_1',
      name: 'Dr. Rajesh Kumar',
      specialization: 'Cardiologist',
      phone: '+919876543210',
      active: true,
    );

    const activeDoc2 = Doctor(
      id: 'DOC_2',
      name: 'Dr. Sneha Patel',
      specialization: 'Pediatrician',
      phone: '+919811223344',
      active: true,
    );

    const inactiveDoc = Doctor(
      id: 'DOC_INACTIVE',
      name: 'Dr. Inactive Specialist',
      specialization: 'Neurologist',
      phone: '+919999999999',
      active: false,
    );

    const activeChemist1 = Chemist(
      id: 'CHM_1',
      name: 'Apollo Pharmacy',
      phone: '+919876543299',
      address: 'MG Road, Bangalore',
      active: true,
    );

    const activeChemist2 = Chemist(
      id: 'CHM_2',
      name: 'MedPlus Chemist',
      phone: '+919822334455',
      address: 'Indiranagar 100ft Road',
      active: true,
    );

    const inactiveChemist = Chemist(
      id: 'CHM_INACTIVE',
      name: 'Closed Pharmacy',
      phone: '+919000000000',
      address: 'Ghost Town',
      active: false,
    );

    test('OrderDraft model holds doctor and chemist data correctly in memory', () {
      final draft = OrderDraft(
        doctor: activeDoc1,
        chemist: activeChemist1,
      );

      expect(draft.doctorId, 'DOC_1');
      expect(draft.doctorName, 'Dr. Rajesh Kumar');
      expect(draft.doctorSpecialization, 'Cardiologist');
      expect(draft.doctorPhone, '+919876543210');

      expect(draft.chemistId, 'CHM_1');
      expect(draft.chemistName, 'Apollo Pharmacy');
      expect(draft.chemistPhone, '+919876543299');
      expect(draft.chemistAddress, 'MG Road, Bangalore');

      final updatedDraft = draft.copyWith(doctor: activeDoc2);
      expect(updatedDraft.doctorId, 'DOC_2');
      expect(updatedDraft.doctorName, 'Dr. Sneha Patel');
      expect(updatedDraft.chemistId, 'CHM_1');
    });

    testWidgets('CreateOrderScreen renders step indicator and active doctors only',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeDoctorsStreamProvider.overrideWith(
              (ref) => Stream.value([activeDoc1, activeDoc2, inactiveDoc]),
            ),
            activeChemistsStreamProvider.overrideWith(
              (ref) => Stream.value([activeChemist1, activeChemist2]),
            ),
          ],
          child: const MaterialApp(
            home: CreateOrderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step indicator
      expect(find.text('Step 1 of 2'), findsOneWidget);
      expect(find.text('Doctor & Chemist'), findsOneWidget);
      expect(find.text('Select Doctor'), findsOneWidget);
      expect(find.text('Select Chemist'), findsOneWidget);

      // Active doctors rendered
      expect(find.text('Dr. Rajesh Kumar'), findsOneWidget);
      expect(find.text('Cardiologist'), findsOneWidget);
      expect(find.text('Dr. Sneha Patel'), findsOneWidget);
      expect(find.text('Pediatrician'), findsOneWidget);

      // Inactive doctor NOT rendered
      expect(find.text('Dr. Inactive Specialist'), findsNothing);

      // Continue button rendered
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Doctor search filters by name, specialization, and phone',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeDoctorsStreamProvider.overrideWith(
              (ref) => Stream.value([activeDoc1, activeDoc2]),
            ),
            activeChemistsStreamProvider.overrideWith(
              (ref) => Stream.value([activeChemist1]),
            ),
          ],
          child: const MaterialApp(
            home: CreateOrderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Search by name
      await tester.enterText(find.widgetWithText(TextField, 'Search doctors...'), 'Sneha');
      await tester.pumpAndSettle();

      expect(find.text('Dr. Sneha Patel'), findsOneWidget);
      expect(find.text('Dr. Rajesh Kumar'), findsNothing);

      // Search by specialization
      await tester.enterText(find.widgetWithText(TextField, 'Search doctors...'), 'Cardio');
      await tester.pumpAndSettle();

      expect(find.text('Dr. Rajesh Kumar'), findsOneWidget);
      expect(find.text('Dr. Sneha Patel'), findsNothing);

      // Search by phone
      await tester.enterText(find.widgetWithText(TextField, 'Search doctors...'), '981122');
      await tester.pumpAndSettle();

      expect(find.text('Dr. Sneha Patel'), findsOneWidget);
      expect(find.text('Dr. Rajesh Kumar'), findsNothing);

      // Search with no results
      await tester.enterText(find.widgetWithText(TextField, 'Search doctors...'), 'Nonexistent');
      await tester.pumpAndSettle();

      expect(find.text('No doctors found.'), findsOneWidget);
    });

    testWidgets('Chemist tab displays active chemists and filters by search',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeDoctorsStreamProvider.overrideWith(
              (ref) => Stream.value([activeDoc1]),
            ),
            activeChemistsStreamProvider.overrideWith(
              (ref) => Stream.value([activeChemist1, activeChemist2, inactiveChemist]),
            ),
          ],
          child: const MaterialApp(
            home: CreateOrderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Chemist tab
      await tester.tap(find.text('Select Chemist'));
      await tester.pumpAndSettle();

      // Active chemists rendered
      expect(find.text('Apollo Pharmacy'), findsOneWidget);
      expect(find.text('MG Road, Bangalore'), findsOneWidget);
      expect(find.text('MedPlus Chemist'), findsOneWidget);

      // Inactive chemist NOT rendered
      expect(find.text('Closed Pharmacy'), findsNothing);

      // Search chemists by address
      await tester.enterText(find.widgetWithText(TextField, 'Search chemists...'), 'Indiranagar');
      await tester.pumpAndSettle();

      expect(find.text('MedPlus Chemist'), findsOneWidget);
      expect(find.text('Apollo Pharmacy'), findsNothing);

      // Search chemists with no results
      await tester.enterText(find.widgetWithText(TextField, 'Search chemists...'), 'Nonexistent');
      await tester.pumpAndSettle();

      expect(find.text('No chemists found.'), findsOneWidget);
    });

    testWidgets('Empty list shows proper placeholder messages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeDoctorsStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
            activeChemistsStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: const MaterialApp(
            home: CreateOrderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Doctor empty state
      expect(find.text('No active doctors available.'), findsOneWidget);

      // Switch to Chemist tab
      await tester.tap(find.text('Select Chemist'));
      await tester.pumpAndSettle();

      // Chemist empty state
      expect(find.text('No active chemists available.'), findsOneWidget);
    });

    testWidgets('Full selection workflow: select doctor, select chemist, continue to AddMedicinesScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeDoctorsStreamProvider.overrideWith(
              (ref) => Stream.value([activeDoc1, activeDoc2]),
            ),
            activeChemistsStreamProvider.overrideWith(
              (ref) => Stream.value([activeChemist1, activeChemist2]),
            ),
          ],
          child: const MaterialApp(
            home: CreateOrderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially neither doctor nor chemist is selected
      expect(find.text('Doctor (Optional)'), findsOneWidget);
      expect(find.text('Chemist required *'), findsOneWidget);

      // Tap Continue before selecting chemist -> triggers SnackBar indicating chemist is missing
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Please select or enter a chemist to continue.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Switch to Doctor tab to select doctor
      await tester.tap(find.text('Select Doctor'));
      await tester.pumpAndSettle();

      // Select Doctor 1
      await tester.tap(find.text('Dr. Rajesh Kumar'));
      await tester.pumpAndSettle();

      // Doctor is selected: chip updates and doctor name appears in status
      expect(find.text('Dr. Rajesh Kumar'), findsWidgets);

      // Tap Continue before selecting chemist -> triggers SnackBar indicating chemist is missing
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Please select or enter a chemist to continue.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Switch to Chemist tab (if not already there)
      await tester.tap(find.text('Select Chemist'));
      await tester.pumpAndSettle();

      // Select Chemist 1
      await tester.tap(find.text('Apollo Pharmacy'));
      await tester.pumpAndSettle();

      // Both selected: doctor and chemist status chips show selected names
      expect(find.text('Apollo Pharmacy'), findsWidgets);

      // Switching back to Doctor tab preserves selected doctor
      await tester.tap(find.text('Select Doctor'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Rajesh Kumar'), findsWidgets);

      // Tap Continue now that both are selected
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Navigated to AddMedicinesScreen
      expect(find.byType(AddMedicinesScreen), findsOneWidget);
      expect(find.text('Add Medicines'), findsOneWidget);

      // Verified passed forward data in order context bar
      expect(find.text('Dr. Rajesh Kumar'), findsWidgets);
      expect(find.text('Apollo Pharmacy'), findsWidgets);
      expect(find.text('Medicines Catalog'), findsOneWidget);
      expect(find.text('Cart (0 items)'), findsOneWidget);
    });
  });

  group('Medicine, Variant, Quantity, and Cart Flow Tests', () {
    const testDoc = Doctor(
      id: 'DOC_1',
      name: 'Dr. Rajesh Kumar',
      specialization: 'Cardiologist',
      phone: '+919876543210',
      active: true,
    );

    const testChemist = Chemist(
      id: 'CHM_1',
      name: 'Apollo Pharmacy',
      phone: '+919876543299',
      address: 'MG Road, Bangalore',
      active: true,
    );

    const activeMed1 = Medicine(
      id: 'MED_1',
      name: 'Azithromycin',
      brand: 'AziBest',
      composition: 'Azithromycin 250mg/500mg',
      category: 'Antibiotic',
      active: true,
    );

    const activeMed2 = Medicine(
      id: 'MED_2',
      name: 'Paracetamol',
      brand: 'Calpol',
      composition: 'Paracetamol 650mg',
      category: 'Analgesic',
      active: true,
    );

    const inactiveMed = Medicine(
      id: 'MED_INACTIVE',
      name: 'Banned Drug',
      brand: 'OldBrand',
      composition: 'Discontinued Chem',
      category: 'Other',
      active: false,
    );

    const activeVariant1 = MedicineVariant(
      id: 'VAR_1',
      medicineId: 'MED_1',
      form: 'Tablet',
      strength: '250 mg',
      packSize: '10 tablets',
      mrp: 80.0,
      supplierPrice: 60.0,
      active: true,
    );

    const activeVariant2 = MedicineVariant(
      id: 'VAR_2',
      medicineId: 'MED_1',
      form: 'Tablet',
      strength: '500 mg',
      packSize: '10 tablets',
      mrp: 120.0,
      supplierPrice: 90.0,
      active: true,
    );

    const inactiveVariant = MedicineVariant(
      id: 'VAR_INACTIVE',
      medicineId: 'MED_1',
      form: 'Tablet',
      strength: '100 mg',
      packSize: '5 tablets',
      mrp: 40.0,
      supplierPrice: 30.0,
      active: false,
    );

    test('OrderDraftItem model calculates itemTotal and copyWith correctly', () {
      const item = OrderDraftItem(
        medicineId: 'MED_1',
        medicineName: 'Azithromycin',
        brand: 'AziBest',
        composition: 'Azithromycin',
        variantId: 'VAR_1',
        form: 'Tablet',
        strength: '250 mg',
        packSize: '10 tablets',
        mrp: 80.0,
        supplierPrice: 60.0,
        quantity: 10,
      );

      expect(item.itemTotal, 600.0);
      final updated = item.copyWith(quantity: 15);
      expect(updated.quantity, 15);
      expect(updated.itemTotal, 900.0);
    });

    test('OrderDraft aggregates totalItems, totalQuantity, and totalAmount correctly', () {
      const item1 = OrderDraftItem(
        medicineId: 'MED_1',
        medicineName: 'Azithromycin',
        brand: 'AziBest',
        composition: 'Azithromycin',
        variantId: 'VAR_1',
        form: 'Tablet',
        strength: '250 mg',
        packSize: '10 tablets',
        mrp: 80.0,
        supplierPrice: 60.0,
        quantity: 10,
      );

      const item2 = OrderDraftItem(
        medicineId: 'MED_1',
        medicineName: 'Azithromycin',
        brand: 'AziBest',
        composition: 'Azithromycin',
        variantId: 'VAR_2',
        form: 'Tablet',
        strength: '500 mg',
        packSize: '10 tablets',
        mrp: 120.0,
        supplierPrice: 90.0,
        quantity: 5,
      );

      final draft = OrderDraft(
        doctor: testDoc,
        chemist: testChemist,
        items: [item1, item2],
      );

      expect(draft.totalItems, 2);
      expect(draft.totalQuantity, 15);
      expect(draft.totalAmount, 1050.0);
      expect(draft.isNotEmpty, isTrue);
      expect(draft.isEmpty, isFalse);
    });

    testWidgets('AddMedicinesScreen displays active medicines and excludes inactive medicines',
        (WidgetTester tester) async {
      final draft = OrderDraft(doctor: testDoc, chemist: testChemist);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeMedicinesStreamProvider.overrideWith(
              (ref) => Stream.value([activeMed1, activeMed2, inactiveMed]),
            ),
          ],
          child: MaterialApp(
            home: AddMedicinesScreen(orderDraft: draft),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Azithromycin'), findsOneWidget);
      expect(find.text('Paracetamol'), findsOneWidget);
      expect(find.text('Banned Drug'), findsNothing);
    });

    testWidgets('Medicine search filters by name, brand, composition, category',
        (WidgetTester tester) async {
      final draft = OrderDraft(doctor: testDoc, chemist: testChemist);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeMedicinesStreamProvider.overrideWith(
              (ref) => Stream.value([activeMed1, activeMed2]),
            ),
          ],
          child: MaterialApp(
            home: AddMedicinesScreen(orderDraft: draft),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Search by composition
      await tester.enterText(
        find.widgetWithText(TextField, 'Search medicines...'),
        '650mg',
      );
      await tester.pumpAndSettle();

      expect(find.text('Paracetamol'), findsOneWidget);
      expect(find.text('Azithromycin'), findsNothing);

      // Search with no results
      await tester.enterText(
        find.widgetWithText(TextField, 'Search medicines...'),
        'Nonexistent',
      );
      await tester.pumpAndSettle();

      expect(find.text('No medicines found.'), findsOneWidget);
    });

    testWidgets('Variant modal displays active variants and excludes inactive variants',
        (WidgetTester tester) async {
      final draft = OrderDraft(doctor: testDoc, chemist: testChemist);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeMedicinesStreamProvider.overrideWith(
              (ref) => Stream.value([activeMed1]),
            ),
            activeMedicineVariantsProvider('MED_1').overrideWith(
              (ref) => Stream.value([activeVariant1, activeVariant2, inactiveVariant]),
            ),
          ],
          child: MaterialApp(
            home: AddMedicinesScreen(orderDraft: draft),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on medicine to open variant modal
      await tester.tap(find.text('Azithromycin'));
      await tester.pumpAndSettle();

      // Active variants displayed
      expect(find.text('Tablet • 250 mg • 10 tablets'), findsOneWidget);
      expect(find.text('Tablet • 500 mg • 10 tablets'), findsOneWidget);

      // Inactive variant NOT displayed
      expect(find.text('Tablet • 100 mg • 5 tablets'), findsNothing);

      // Prices displayed
      expect(find.text('MRP ₹80.00'), findsOneWidget);
      expect(find.text('Supplier ₹60.00'), findsOneWidget);
      expect(find.text('MRP ₹120.00'), findsOneWidget);
      expect(find.text('Supplier ₹90.00'), findsOneWidget);
    });

    testWidgets('Add to cart, increase quantity on exact variant, and separate different variants',
        (WidgetTester tester) async {
      final draft = OrderDraft(doctor: testDoc, chemist: testChemist);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeMedicinesStreamProvider.overrideWith(
              (ref) => Stream.value([activeMed1]),
            ),
            activeMedicineVariantsProvider('MED_1').overrideWith(
              (ref) => Stream.value([activeVariant1, activeVariant2]),
            ),
          ],
          child: MaterialApp(
            home: AddMedicinesScreen(orderDraft: draft),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open variant modal
      await tester.tap(find.text('Azithromycin'));
      await tester.pumpAndSettle();

      // Select Variant 1 (250 mg)
      await tester.tap(find.text('Tablet • 250 mg • 10 tablets'));
      await tester.pumpAndSettle();

      // Set quantity to 10
      await tester.enterText(
        find.descendant(
          of: find.byType(Dialog).evaluate().isEmpty
              ? find.byType(BottomSheet)
              : find.byType(Dialog),
          matching: find.byType(TextField),
        ),
        '10',
      );
      await tester.pumpAndSettle();

      // Tap Add to Cart
      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      // Cart now has 1 item with quantity 10, total 600.00
      expect(find.text('Cart (1 items)'), findsOneWidget);
      expect(find.text('10 units'), findsOneWidget);
      expect(find.text('₹600.00'), findsWidgets);

      // Add the exact same variant again with quantity 5
      await tester.tap(find.widgetWithText(OutlinedButton, 'Variants').first);
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Tablet • 250 mg • 10 tablets'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(TextField),
        ),
        '5',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      // Still 1 item line, but quantity increased to 15 (60 * 15 = 900.00)
      expect(find.text('Cart (1 items)'), findsOneWidget);
      expect(find.text('15 units'), findsOneWidget);
      expect(find.text('₹900.00'), findsWidgets);

      // Add a different variant (500 mg) with quantity 5
      await tester.tap(find.widgetWithText(OutlinedButton, 'Variants').first);
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Tablet • 500 mg • 10 tablets'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(TextField),
        ),
        '5',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      // Now 2 separate items in cart, total units = 20, total amount = 900 + 450 = 1350.00
      expect(find.text('Cart (2 items)'), findsOneWidget);
      expect(find.text('20 units'), findsOneWidget);
      expect(find.text('₹1350.00'), findsOneWidget);
    });

    testWidgets('Inline quantity edit and item removal in cart',
        (WidgetTester tester) async {
      const item = OrderDraftItem(
        medicineId: 'MED_1',
        medicineName: 'Azithromycin',
        brand: 'AziBest',
        composition: 'Azithromycin',
        variantId: 'VAR_1',
        form: 'Tablet',
        strength: '250 mg',
        packSize: '10 tablets',
        mrp: 80.0,
        supplierPrice: 60.0,
        quantity: 2,
      );

      final draft = OrderDraft(
        doctor: testDoc,
        chemist: testChemist,
        items: [item],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeMedicinesStreamProvider.overrideWith(
              (ref) => Stream.value([activeMed1]),
            ),
          ],
          child: MaterialApp(
            home: AddMedicinesScreen(orderDraft: draft),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Cart (1 items)'), findsOneWidget);
      expect(find.text('2 units'), findsOneWidget);
      expect(find.text('₹120.00'), findsWidgets);

      // Increment quantity using inline '+' button
      final incButton = find.byIcon(Icons.add);
      await tester.ensureVisible(incButton);
      await tester.tap(incButton);
      await tester.pumpAndSettle();

      expect(find.text('3 units'), findsOneWidget);
      expect(find.text('₹180.00'), findsWidgets);

      // Decrement quantity using inline '-' button
      final decButton = find.byIcon(Icons.remove);
      await tester.ensureVisible(decButton);
      await tester.tap(decButton);
      await tester.pumpAndSettle();

      expect(find.text('2 units'), findsOneWidget);
      expect(find.text('₹120.00'), findsWidgets);

      // Remove item using trash icon
      final deleteButton = find.byIcon(Icons.delete_outline_rounded);
      await tester.ensureVisible(deleteButton);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.text('Cart is empty.'), findsOneWidget);
      expect(find.text('Cart (0 items)'), findsOneWidget);
    });

    testWidgets('Empty cart validation when attempting to review order',
        (WidgetTester tester) async {
      final draft = OrderDraft(doctor: testDoc, chemist: testChemist);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeMedicinesStreamProvider.overrideWith(
              (ref) => Stream.value([activeMed1]),
            ),
          ],
          child: MaterialApp(
            home: AddMedicinesScreen(orderDraft: draft),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Review Order on empty cart -> shows warning SnackBar
      await tester.tap(find.text('Review Order'));
      await tester.pumpAndSettle();

      expect(
        find.text('Add at least one medicine before reviewing the order.'),
        findsOneWidget,
      );
    });

    testWidgets('ReviewOrderScreen displays Doctor, Chemist, cart items and total correctly',
        (WidgetTester tester) async {
      const item1 = OrderDraftItem(
        medicineId: 'MED_1',
        medicineName: 'Azithromycin',
        brand: 'AziBest',
        composition: 'Azithromycin 250mg',
        variantId: 'VAR_1',
        form: 'Tablet',
        strength: '250 mg',
        packSize: '10 tablets',
        mrp: 80.0,
        supplierPrice: 60.0,
        quantity: 10,
      );

      const item2 = OrderDraftItem(
        medicineId: 'MED_1',
        medicineName: 'Azithromycin',
        brand: 'AziBest',
        composition: 'Azithromycin 500mg',
        variantId: 'VAR_2',
        form: 'Tablet',
        strength: '500 mg',
        packSize: '10 tablets',
        mrp: 120.0,
        supplierPrice: 90.0,
        quantity: 5,
      );

      final draft = OrderDraft(
        doctor: testDoc,
        chemist: testChemist,
        items: [item1, item2],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReviewOrderScreen(orderDraft: draft),
        ),
      );

      await tester.pumpAndSettle();

      // Doctor & Chemist details
      expect(find.text('Doctor: Dr. Rajesh Kumar'), findsOneWidget);
      expect(find.text('Chemist: Apollo Pharmacy'), findsOneWidget);

      // Cart Items
      expect(find.text('Cart Items (2)'), findsOneWidget);
      expect(find.text('15 units'), findsWidgets);
      expect(find.text('₹600.00'), findsOneWidget);
      expect(find.text('₹450.00'), findsOneWidget);
      expect(find.text('₹1050.00'), findsOneWidget);

      // Tapping Submit Order shows confirmation dialog
      await tester.ensureVisible(find.text('Submit Order'));
      await tester.tap(find.text('Submit Order'));
      await tester.pumpAndSettle();

      expect(find.text('Submit this order?'), findsOneWidget);
      expect(find.text('Doctor: Dr. Rajesh Kumar'), findsWidgets);
      expect(find.text('Chemist: Apollo Pharmacy'), findsWidgets);
      expect(find.text('Total items: 2'), findsOneWidget);
      expect(find.text('Total quantity: 15 units'), findsOneWidget);
      expect(find.text('Total amount: ₹1050.00'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Submit this order?'), findsNothing);
    });
  });

  group('Order & Submission Management Tests', () {
    test('1. Order model serialization and deserialization', () {
      final now = DateTime(2026, 9, 26, 12, 0);
      const item = OrderItem(
        medicineId: 'm1',
        medicineName: 'Azithromycin',
        brand: 'Test Pharma',
        composition: 'Azithromycin',
        variantId: 'v1',
        form: 'Tablet',
        strength: '250 mg',
        packSize: '10 tablets',
        mrp: 80,
        supplierPrice: 60,
        quantity: 10,
        itemTotal: 600,
      );

      final order = OrderModel(
        id: 'ord_1',
        orderNumber: 'ORD-20260926-0001',
        representative: {
          'id': 'rep_1',
          'name': 'Rahul Sharma',
          'email': 'rahul@example.com',
        },
        doctor: {
          'id': 'doc_1',
          'name': 'Dr. John Smith',
          'specialization': 'Cardiologist',
          'phone': '9876543210',
        },
        chemist: {
          'id': 'chm_1',
          'name': 'Apollo Pharmacy',
          'phone': '9876543210',
          'address': 'MG Road, Bangalore',
        },
        items: const [item],
        totalItems: 1,
        totalQuantity: 10,
        totalAmount: 600.0,
        status: 'pending',
        createdAt: now,
        updatedAt: now,
      );

      final map = order.toMap();
      expect(map['orderNumber'], 'ORD-20260926-0001');
      expect(map['status'], 'pending');
      expect(map['totalItems'], 1);
      expect(map['totalQuantity'], 10);
      expect(map['totalAmount'], 600.0);

      final reconstructed = OrderModel.fromFirestore(map, 'ord_1');
      expect(reconstructed.id, 'ord_1');
      expect(reconstructed.orderNumber, 'ORD-20260926-0001');
      expect(reconstructed.representativeId, 'rep_1');
      expect(reconstructed.representativeName, 'Rahul Sharma');
      expect(reconstructed.representativeEmail, 'rahul@example.com');
      expect(reconstructed.doctorId, 'doc_1');
      expect(reconstructed.doctorName, 'Dr. John Smith');
      expect(reconstructed.doctorSpecialization, 'Cardiologist');
      expect(reconstructed.doctorPhone, '9876543210');
      expect(reconstructed.chemistId, 'chm_1');
      expect(reconstructed.chemistName, 'Apollo Pharmacy');
      expect(reconstructed.chemistPhone, '9876543210');
      expect(reconstructed.chemistAddress, 'MG Road, Bangalore');
      expect(reconstructed.items.length, 1);
      expect(reconstructed.items.first.medicineName, 'Azithromycin');
    });

    test('2. Order item serialization and deserialization', () {
      const draftItem = OrderDraftItem(
        medicineId: 'med_1',
        medicineName: 'Amoxicillin',
        brand: 'HealthCorp',
        composition: 'Amoxicillin 500mg',
        variantId: 'var_1',
        form: 'Capsule',
        strength: '500 mg',
        packSize: '15 capsules',
        mrp: 150.0,
        supplierPrice: 110.0,
        quantity: 4,
      );

      final orderItem = OrderItem.fromDraftItem(draftItem);
      expect(orderItem.itemTotal, 440.0);

      final map = orderItem.toMap();
      expect(map['medicineId'], 'med_1');
      expect(map['medicineName'], 'Amoxicillin');
      expect(map['form'], 'Capsule');
      expect(map['supplierPrice'], 110.0);
      expect(map['quantity'], 4);
      expect(map['itemTotal'], 440.0);

      final fromMapItem = OrderItem.fromMap(map);
      expect(fromMapItem.medicineId, 'med_1');
      expect(fromMapItem.packSize, '15 capsules');
      expect(fromMapItem.supplierPrice, 110.0);
      expect(fromMapItem.itemTotal, 440.0);
    });

    test('3. Order total calculation across draft items', () {
      const item1 = OrderDraftItem(
        medicineId: 'm1',
        medicineName: 'Med 1',
        brand: 'B1',
        composition: 'C1',
        variantId: 'v1',
        form: 'Tab',
        strength: '10mg',
        packSize: '10',
        mrp: 50.0,
        supplierPrice: 40.0,
        quantity: 5,
      );
      const item2 = OrderDraftItem(
        medicineId: 'm2',
        medicineName: 'Med 2',
        brand: 'B2',
        composition: 'C2',
        variantId: 'v2',
        form: 'Cap',
        strength: '20mg',
        packSize: '20',
        mrp: 100.0,
        supplierPrice: 80.0,
        quantity: 2,
      );

      final draft = OrderDraft(
        doctor: const Doctor(
          id: 'd1',
          name: 'Doc',
          specialization: 'Spec',
          phone: '1234567890',
          active: true,
        ),
        chemist: const Chemist(
          id: 'c1',
          name: 'Chem',
          phone: '1234567890',
          address: 'Addr',
          active: true,
        ),
        items: const [item1, item2],
      );

      expect(draft.totalItems, 2);
      expect(draft.totalQuantity, 7);
      expect(draft.totalAmount, (40.0 * 5) + (80.0 * 2));
    });

    test('4. Order number format follows ORD-YYYYMMDD-XXXX', () {
      const orderNumber = 'ORD-20260926-0001';
      final orderRegex = RegExp(r'^ORD-\d{8}-\d{4}$');
      expect(orderRegex.hasMatch(orderNumber), isTrue);
      expect(orderNumber.startsWith('ORD-20260926-'), isTrue);
    });

    testWidgets('5. Submit confirmation dialog and cancel handling',
        (tester) async {
      final fakeOrderService = _FakeOrderService();
      final draft = _createSampleDraft();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: MaterialApp(
            home: ReviewOrderScreen(orderDraft: draft),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Submit Order'));
      await tester.tap(find.text('Submit Order'));
      await tester.pumpAndSettle();

      expect(find.text('Submit this order?'), findsOneWidget);
      expect(find.text('Doctor: Dr. Test'), findsWidgets);
      expect(find.text('Chemist: Test Pharmacy'), findsWidgets);
      expect(find.text('Total items: 1'), findsOneWidget);
      expect(find.text('Total quantity: 5 units'), findsOneWidget);
      expect(find.text('Total amount: ₹250.00'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Submit this order?'), findsNothing);
      expect(fakeOrderService.submissionAttempts, 0);
    });

    testWidgets('6. Submit loading state and duplicate submission prevention',
        (tester) async {
      final fakeOrderService = _FakeOrderService();
      final completer = Completer<OrderModel>();
      fakeOrderService.submitCompleter = completer;
      final draft = _createSampleDraft();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: MaterialApp(
            home: ReviewOrderScreen(orderDraft: draft),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Submit Order'));
      await tester.tap(find.text('Submit Order'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Submitting Order...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.text('Submitting Order...'), warnIfMissed: false);
      await tester.pump();
      expect(fakeOrderService.submissionAttempts, 1);

      completer.complete(_createSampleOrder());
      await tester.pumpAndSettle();

      expect(find.text('Order Submitted'), findsOneWidget);
    });

    testWidgets('7. Successful submission navigates to OrderSuccessScreen',
        (tester) async {
      final fakeOrderService = _FakeOrderService();
      final draft = _createSampleDraft();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: MaterialApp(
            home: ReviewOrderScreen(orderDraft: draft),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Submit Order'));
      await tester.tap(find.text('Submit Order'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Order Submitted'), findsOneWidget);
      expect(find.text('ORD-20260926-0001'), findsOneWidget);
      expect(find.text('View My Orders'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('8. Failed submission keeps draft intact and displays SnackBar',
        (tester) async {
      final fakeOrderService = _FakeOrderService()..shouldFail = true;
      final draft = _createSampleDraft();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: MaterialApp(
            home: ReviewOrderScreen(orderDraft: draft),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Submit Order'));
      await tester.tap(find.text('Submit Order'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to submit order'), findsOneWidget);
      expect(find.text('Review Order'), findsOneWidget);
      expect(find.text('Doctor: Dr. Test'), findsOneWidget);
      expect(find.text('Submit Order'), findsOneWidget);
    });

    testWidgets('9. Success screen displays complete order details and buttons',
        (tester) async {
      final order = _createSampleOrder();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: OrderSuccessScreen(order: order),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Order Submitted'), findsOneWidget);
      expect(find.text('ORD-20260926-0001'), findsOneWidget);
      expect(find.text('Dr. Test'), findsOneWidget);
      expect(find.text('Test Pharmacy'), findsOneWidget);
      expect(find.text('₹250.00'), findsOneWidget);
      expect(find.text('View My Orders'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('10. My Orders displays only representative\'s orders',
        (tester) async {
      final repOrder = _createSampleOrder(id: 'ord_mine', repId: 'rep_current');
      final fakeOrderService = _FakeOrderService()..orders.add(repOrder);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
            authStateProvider.overrideWith(
              (ref) => Stream.value(_MockUserWithUid('rep_current')),
            ),
          ],
          child: const MaterialApp(
            home: RepresentativeOrdersScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(repOrder.orderNumber), findsOneWidget);
      expect(find.text('Dr. Test'), findsOneWidget);
      expect(find.text('Test Pharmacy'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('11. Order details screen displays full snapshot',
        (tester) async {
      final order = _createSampleOrder();
      final fakeOrderService = _FakeOrderService()..orders.add(order);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: MaterialApp(
            home: RepresentativeOrderDetailsScreen(
              orderId: order.id,
              initialOrder: order,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(order.orderNumber), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('Dr. Test'), findsOneWidget);
      expect(find.text('Test Pharmacy'), findsOneWidget);
      expect(find.text('Paracetamol'), findsOneWidget);
      expect(find.text('₹250.00'), findsWidgets);
    });

    testWidgets('12. Empty orders state displays "No orders yet."',
        (tester) async {
      final fakeOrderService = _FakeOrderService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
            authStateProvider.overrideWith(
              (ref) => Stream.value(_MockUserWithUid('rep_empty')),
            ),
          ],
          child: const MaterialApp(
            home: RepresentativeOrdersScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No orders yet.'), findsOneWidget);
      expect(find.text('Create New Order'), findsWidgets);
    });

    testWidgets('13. Order status display formatting', (tester) async {
      final orderApproved = _createSampleOrder(
        id: 'ord_appr',
        status: 'approved',
      );
      final fakeOrderService = _FakeOrderService()..orders.add(orderApproved);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
            authStateProvider.overrideWith(
              (ref) => Stream.value(_MockUserWithUid('rep_current')),
            ),
          ],
          child: const MaterialApp(
            home: RepresentativeOrdersScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('APPROVED'), findsOneWidget);
    });
  });

  group('Admin Orders Management Tests', () {
    testWidgets('1. Admin Orders screen renders list with order cards', (tester) async {
      final fakeOrderService = _FakeOrderService();
      final order1 = _createSampleOrder(
        id: 'ord_1',
        orderNumber: 'ORD-20260926-0001',
        status: 'pending',
      );
      final order2 = _createSampleOrder(
        id: 'ord_2',
        orderNumber: 'ORD-20260926-0002',
        status: 'confirmed',
      );
      fakeOrderService.orders.addAll([order1, order2]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: const MaterialApp(
            home: AdminOrdersScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Orders Management'), findsOneWidget);
      expect(find.text('ORD-20260926-0001'), findsOneWidget);
      expect(find.text('ORD-20260926-0002'), findsOneWidget);
      expect(find.text('Rep: Rahul Sharma'), findsWidgets);
      expect(find.text('Dr. Test'), findsWidgets);
      expect(find.text('Test Pharmacy'), findsWidgets);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('CONFIRMED'), findsOneWidget);
    });

    testWidgets('2. Status filtering filters orders by status chip', (tester) async {
      final fakeOrderService = _FakeOrderService();
      final orderPending = _createSampleOrder(id: 'ord_pend', status: 'pending');
      final orderDelivered = OrderModel(
        id: 'ord_deliv',
        orderNumber: 'ORD-20260926-0002',
        representative: const {'id': 'r2', 'name': 'Priya Singh', 'email': 'priya@example.com'},
        doctor: const {'id': 'd2', 'name': 'Dr. Sharma', 'specialization': 'ENT', 'phone': '9876543211'},
        chemist: const {'id': 'c2', 'name': 'City Meds', 'phone': '9876543211', 'address': 'City Center'},
        items: const [],
        totalItems: 0,
        totalQuantity: 0,
        totalAmount: 0.0,
        status: 'delivered',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      fakeOrderService.orders.addAll([orderPending, orderDelivered]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: const MaterialApp(
            home: AdminOrdersScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially 'All' is selected -> both orders visible
      expect(find.text('ORD-20260926-0001'), findsOneWidget);
      expect(find.text('ORD-20260926-0002'), findsOneWidget);

      // Tap 'Delivered' chip
      await tester.tap(find.widgetWithText(FilterChip, 'Delivered'));
      await tester.pumpAndSettle();

      expect(find.text('ORD-20260926-0001'), findsNothing);
      expect(find.text('ORD-20260926-0002'), findsOneWidget);
      expect(find.text('DELIVERED'), findsOneWidget);

      // Tap 'Pending' chip
      await tester.tap(find.widgetWithText(FilterChip, 'Pending'));
      await tester.pumpAndSettle();

      expect(find.text('ORD-20260926-0001'), findsOneWidget);
      expect(find.text('ORD-20260926-0002'), findsNothing);
      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('3. Search filtering matches order number, rep, doctor, chemist', (tester) async {
      final fakeOrderService = _FakeOrderService();
      final order1 = OrderModel(
        id: 'o1',
        orderNumber: 'ORD-20260926-0010',
        representative: const {'id': 'r1', 'name': 'Rahul Sharma', 'email': 'rahul@med.com'},
        doctor: const {'id': 'd1', 'name': 'Dr. Gupta', 'specialization': 'Pediatrician', 'phone': '1234567890'},
        chemist: const {'id': 'c1', 'name': 'Apollo Bangalore', 'phone': '1234567890', 'address': 'MG Road'},
        items: const [],
        totalItems: 0,
        totalQuantity: 0,
        totalAmount: 100.0,
        status: 'pending',
      );
      final order2 = OrderModel(
        id: 'o2',
        orderNumber: 'ORD-20260926-0020',
        representative: const {'id': 'r2', 'name': 'Ankit Verma', 'email': 'ankit@med.com'},
        doctor: const {'id': 'd2', 'name': 'Dr. Mehta', 'specialization': 'Surgeon', 'phone': '1234567891'},
        chemist: const {'id': 'c2', 'name': 'Wellness Pharmacy', 'phone': '1234567891', 'address': 'Ring Road'},
        items: const [],
        totalItems: 0,
        totalQuantity: 0,
        totalAmount: 200.0,
        status: 'confirmed',
      );
      fakeOrderService.orders.addAll([order1, order2]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: const MaterialApp(
            home: AdminOrdersScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Search by chemist name
      await tester.enterText(find.byType(TextField), 'Wellness');
      await tester.pumpAndSettle();
      expect(find.text('ORD-20260926-0020'), findsOneWidget);
      expect(find.text('ORD-20260926-0010'), findsNothing);

      // Search by rep name
      await tester.enterText(find.byType(TextField), 'Rahul');
      await tester.pumpAndSettle();
      expect(find.text('ORD-20260926-0010'), findsOneWidget);
      expect(find.text('ORD-20260926-0020'), findsNothing);

      // Search by doctor name
      await tester.enterText(find.byType(TextField), 'Mehta');
      await tester.pumpAndSettle();
      expect(find.text('ORD-20260926-0020'), findsOneWidget);
      expect(find.text('ORD-20260926-0010'), findsNothing);

      // Search by order number
      await tester.enterText(find.byType(TextField), '0010');
      await tester.pumpAndSettle();
      expect(find.text('ORD-20260926-0010'), findsOneWidget);
      expect(find.text('ORD-20260926-0020'), findsNothing);

      // Search with non-matching query shows no match view
      await tester.enterText(find.byType(TextField), 'NonExistent');
      await tester.pumpAndSettle();
      expect(find.text('No matching orders'), findsOneWidget);
      expect(find.text('Clear Filters'), findsOneWidget);

      await tester.tap(find.text('Clear Filters'));
      await tester.pumpAndSettle();
      expect(find.text('ORD-20260926-0010'), findsOneWidget);
      expect(find.text('ORD-20260926-0020'), findsOneWidget);
    });

    testWidgets('4. Admin order details screen displays all sections', (tester) async {
      final order = _createSampleOrder();
      final fakeOrderService = _FakeOrderService()..orders.add(order);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: MaterialApp(
            home: AdminOrderDetailsScreen(
              orderId: order.id,
              initialOrder: order,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Admin Order Details'), findsOneWidget);
      expect(find.text(order.orderNumber), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('REPRESENTATIVE'), findsOneWidget);
      expect(find.text('Rahul Sharma'), findsOneWidget);
      expect(find.text('rahul@example.com'), findsOneWidget);
      expect(find.text('DOCTOR'), findsOneWidget);
      expect(find.text('Dr. Test'), findsOneWidget);
      expect(find.text('Physician'), findsOneWidget);
      expect(find.text('CHEMIST'), findsOneWidget);
      expect(find.text('Test Pharmacy'), findsOneWidget);
      expect(find.text('123 Test St'), findsOneWidget);
      expect(find.text('MEDICINES (1)'), findsOneWidget);
      expect(find.text('Paracetamol'), findsOneWidget);
      expect(find.text('₹250.00'), findsWidgets);
      expect(find.text('Update Status'), findsOneWidget);
    });

    testWidgets('5. Status update workflow with confirmation dialog and Firestore protection', (tester) async {
      final order = _createSampleOrder(status: 'pending');
      final fakeOrderService = _FakeOrderService()..orders.add(order);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: MaterialApp(
            home: AdminOrderDetailsScreen(
              orderId: order.id,
              initialOrder: order,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Update Status button
      await tester.tap(find.text('Update Status'));
      await tester.pumpAndSettle();

      expect(find.text('Update Order Status'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);

      // Select 'Confirmed'
      await tester.tap(find.text('Confirmed'));
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.text('Update Order Status?'), findsOneWidget);
      expect(find.textContaining('from "PENDING" to "Confirmed"'), findsOneWidget);

      // Tap Confirm
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Verify status was updated in service
      expect(fakeOrderService.lastUpdatedOrderId, order.id);
      expect(fakeOrderService.lastUpdatedStatus, 'confirmed');

      // Verify protected fields remained identical
      final updatedOrder = fakeOrderService.orders.first;
      expect(updatedOrder.orderNumber, order.orderNumber);
      expect(updatedOrder.representative, order.representative);
      expect(updatedOrder.doctor, order.doctor);
      expect(updatedOrder.chemist, order.chemist);
      expect(updatedOrder.items.length, order.items.length);
      expect(updatedOrder.totalAmount, order.totalAmount);
      expect(updatedOrder.status, 'confirmed');
    });

    testWidgets('6. Admin dashboard Orders card navigates to AdminOrdersScreen', (tester) async {
      final fakeOrderService = _FakeOrderService();
      const testUser = AppUser(
        uid: 'admin_uid',
        email: 'admin@med.com',
        name: 'Admin User',
        phone: '+919876543210',
        role: 'admin',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(user: testUser),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Orders card on Dashboard
      await tester.ensureVisible(find.widgetWithText(Card, 'Orders'));
      await tester.tap(find.widgetWithText(Card, 'Orders'));
      await tester.pumpAndSettle();

      expect(find.text('Orders Management'), findsOneWidget);
    });
  });

  group('Dashboard Order Statistics & Filter Navigation Tests', () {
    test('1-7. OrderStatistics counts and total value calculation across statuses', () {
      final orders = [
        _createSampleOrder(id: '1', status: 'pending', totalAmount: 100.0),
        _createSampleOrder(id: '2', status: 'pending', totalAmount: 150.0),
        _createSampleOrder(id: '3', status: 'confirmed', totalAmount: 300.0),
        _createSampleOrder(id: '4', status: 'processing', totalAmount: 200.0),
        _createSampleOrder(id: '5', status: 'processing', totalAmount: 250.0),
        _createSampleOrder(id: '6', status: 'delivered', totalAmount: 400.0),
        _createSampleOrder(id: '7', status: 'delivered', totalAmount: 500.0),
        _createSampleOrder(id: '8', status: 'delivered', totalAmount: 600.0),
        _createSampleOrder(id: '9', status: 'cancelled', totalAmount: 50.0),
      ];

      final stats = OrderStatistics.fromOrders(orders);

      // 1. Total order count
      expect(stats.totalOrders, 9);
      // 2. Pending count
      expect(stats.pendingOrders, 2);
      // 3. Confirmed count
      expect(stats.confirmedOrders, 1);
      // 4. Processing count
      expect(stats.processingOrders, 2);
      // 5. Delivered count
      expect(stats.deliveredOrders, 3);
      // 6. Cancelled count
      expect(stats.cancelledOrders, 1);
      // 7. Total order value
      expect(stats.totalOrderValue, 2550.0);
    });

    test('8. Empty order statistics safely defaults to 0 and 0.0 value', () {
      final stats = OrderStatistics.fromOrders([]);
      expect(stats.totalOrders, 0);
      expect(stats.pendingOrders, 0);
      expect(stats.confirmedOrders, 0);
      expect(stats.processingOrders, 0);
      expect(stats.deliveredOrders, 0);
      expect(stats.cancelledOrders, 0);
      expect(stats.totalOrderValue, 0.0);
    });

    testWidgets('9. Admin statistics calculation derived from all orders and displayed in UI', (tester) async {
      final fakeOrderService = _FakeOrderService();
      fakeOrderService.orders.addAll([
        _createSampleOrder(id: 'o1', repId: 'rep_1', status: 'pending', totalAmount: 1000.0),
        _createSampleOrder(id: 'o2', repId: 'rep_2', status: 'confirmed', totalAmount: 2500.0),
        _createSampleOrder(id: 'o3', repId: 'rep_1', status: 'processing', totalAmount: 1500.0),
        _createSampleOrder(id: 'o4', repId: 'rep_3', status: 'delivered', totalAmount: 5000.0),
        _createSampleOrder(id: 'o5', repId: 'rep_2', status: 'cancelled', totalAmount: 500.0),
      ]);

      const adminUser = AppUser(
        uid: 'admin_1',
        email: 'admin@med.com',
        name: 'Admin Boss',
        phone: '+919876543210',
        role: 'admin',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(user: adminUser),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Order Overview'));
      expect(find.text('Order Overview'), findsOneWidget);
      expect(find.text('Total Orders'), findsOneWidget);
      expect(find.text('Total Value'), findsOneWidget);

      expect(find.text('5'), findsOneWidget);
      expect(find.text('₹10,500'), findsOneWidget);
    });

    testWidgets('10. Representative statistics calculation derived from my orders and displayed in UI', (tester) async {
      final fakeOrderService = _FakeOrderService();
      fakeOrderService.orders.addAll([
        _createSampleOrder(id: 'rep_o1', repId: 'rep_mine', status: 'pending', totalAmount: 1200.0),
        _createSampleOrder(id: 'rep_o2', repId: 'rep_mine', status: 'confirmed', totalAmount: 800.0),
        _createSampleOrder(id: 'rep_o3', repId: 'rep_mine', status: 'delivered', totalAmount: 2000.0),
      ]);

      const repUser = AppUser(
        uid: 'rep_mine',
        email: 'rep@med.com',
        name: 'Field Rep',
        phone: '+919876543211',
        role: 'medical_rep',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
            authStateProvider.overrideWith(
              (ref) => Stream.value(_MockUserWithUid('rep_mine')),
            ),
          ],
          child: const MaterialApp(
            home: RepresentativeDashboardScreen(user: repUser),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('My Order Overview'));
      expect(find.text('My Order Overview'), findsOneWidget);
      expect(find.text('My Order Value'), findsOneWidget);

      expect(find.text('3'), findsOneWidget);
      expect(find.text('₹4,000'), findsOneWidget);
    });

    test('11. Representative statistics use only representative orders, excluding others', () async {
      final fakeOrderService = _FakeOrderService();
      fakeOrderService.orders.addAll([
        _createSampleOrder(id: 'r1_1', repId: 'rep_1', status: 'delivered', totalAmount: 1000.0),
        _createSampleOrder(id: 'r1_2', repId: 'rep_1', status: 'delivered', totalAmount: 2000.0),
        _createSampleOrder(id: 'r2_1', repId: 'rep_2', status: 'delivered', totalAmount: 50000.0),
      ]);

      final container = ProviderContainer(
        overrides: [
          orderServiceProvider.overrideWithValue(fakeOrderService),
          authStateProvider.overrideWith(
            (ref) => Stream.value(_MockUserWithUid('rep_1')),
          ),
        ],
      );

      final repCompleter = Completer<OrderStatistics>();
      final adminCompleter = Completer<OrderStatistics>();

      final repSub = container.listen<AsyncValue<OrderStatistics>>(
        representativeOrderStatisticsProvider,
        (_, next) {
          if (next.hasValue && !repCompleter.isCompleted) {
            repCompleter.complete(next.value!);
          }
        },
        fireImmediately: true,
      );

      final adminSub = container.listen<AsyncValue<OrderStatistics>>(
        adminOrderStatisticsProvider,
        (_, next) {
          if (next.hasValue && !adminCompleter.isCompleted) {
            adminCompleter.complete(next.value!);
          }
        },
        fireImmediately: true,
      );

      final repStats = await repCompleter.future;
      expect(repStats.totalOrders, 2);
      expect(repStats.deliveredOrders, 2);
      expect(repStats.totalOrderValue, 3000.0);

      final adminStats = await adminCompleter.future;
      expect(adminStats.totalOrders, 3);
      expect(adminStats.deliveredOrders, 3);
      expect(adminStats.totalOrderValue, 53000.0);

      repSub.close();
      adminSub.close();
      container.dispose();
    });

    testWidgets('12. Status-card filter navigation for Admin Dashboard', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeOrderService = _FakeOrderService();
      fakeOrderService.orders.addAll([
        _createSampleOrder(id: 'adm_1', repId: 'rep_user', status: 'pending', totalAmount: 500.0),
        _createSampleOrder(id: 'adm_2', repId: 'rep_user', status: 'delivered', totalAmount: 1200.0),
      ]);

      const adminUser = AppUser(
        uid: 'admin_1',
        email: 'admin@med.com',
        name: 'Admin Boss',
        phone: '+919876543210',
        role: 'admin',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
            doctorsStreamProvider.overrideWith((ref) => Stream.value([])),
            chemistsStreamProvider.overrideWith((ref) => Stream.value([])),
            medicalRepsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(user: adminUser),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final adminPendingCard = find.descendant(
        of: find.byType(OrderOverviewSection),
        matching: find.text('Pending'),
      );
      await tester.tap(adminPendingCard);
      await tester.pumpAndSettle();

      expect(find.text('Orders Management'), findsOneWidget);
      final pendingFilterChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Pending'),
      );
      expect(pendingFilterChip.selected, isTrue);
    });

    testWidgets('13. Status-card filter navigation for Representative Dashboard', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeOrderService = _FakeOrderService();
      fakeOrderService.orders.addAll([
        _createSampleOrder(id: 'rep_1', repId: 'rep_user', status: 'pending', totalAmount: 500.0),
        _createSampleOrder(id: 'rep_2', repId: 'rep_user', status: 'delivered', totalAmount: 1200.0),
      ]);

      const repUser = AppUser(
        uid: 'rep_user',
        email: 'rep@med.com',
        name: 'Field Rep',
        phone: '+919876543211',
        role: 'medical_rep',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
            authStateProvider.overrideWith(
              (ref) => Stream.value(_MockUserWithUid('rep_user')),
            ),
          ],
          child: const MaterialApp(
            home: RepresentativeDashboardScreen(user: repUser),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final repDeliveredCard = find.descendant(
        of: find.byType(OrderOverviewSection),
        matching: find.text('Delivered'),
      );
      await tester.tap(repDeliveredCard);
      await tester.pumpAndSettle();

      expect(find.text('My Orders'), findsOneWidget);
      final deliveredFilterChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Delivered'),
      );
      expect(deliveredFilterChip.selected, isTrue);
    });
  });

  group('PDF Order / Invoice Generation Tests', () {
    test('1. PDF service accepts an OrderModel and generates valid PDF bytes', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final order = _createSampleOrder();
      final bytes = await OrderPdfService.generateOrderPdf(order);
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
      final header = String.fromCharCodes(bytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('2. PDF generation handles multiple order items', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final items = List.generate(
        15,
        (i) => OrderItem(
          medicineId: 'med_$i',
          medicineName: 'Medicine Item #$i',
          brand: 'PharmaBrand $i',
          composition: 'Active Formula $i',
          variantId: 'var_$i',
          form: 'Tablet',
          strength: '${(i + 1) * 100} mg',
          packSize: '10x10',
          mrp: (i + 1) * 50.0,
          supplierPrice: (i + 1) * 40.0,
          quantity: i + 1,
          itemTotal: (i + 1) * 40.0 * (i + 1),
        ),
      );
      final multiItemOrder = OrderModel(
        id: 'ord_multi',
        orderNumber: 'ORD-20260927-9999',
        representative: const {
          'id': 'rep_1',
          'name': 'Rahul Sharma',
          'email': 'rahul@med.com',
        },
        doctor: const {
          'id': 'doc_1',
          'name': 'Dr. Gupta',
          'specialization': 'Cardiology',
          'phone': '9876543210',
        },
        chemist: const {
          'id': 'chm_1',
          'name': 'Apollo Pharmacy',
          'phone': '9876543211',
          'address': 'Koramangala, Bangalore',
        },
        items: items,
        totalItems: items.length,
        totalQuantity: items.fold<int>(0, (sum, item) => sum + item.quantity),
        totalAmount: items.fold<double>(0.0, (sum, item) => sum + item.itemTotal),
        status: 'confirmed',
        createdAt: DateTime(2026, 9, 27, 10, 30),
        updatedAt: DateTime(2026, 9, 27, 10, 30),
      );

      final bytes = await OrderPdfService.generateOrderPdf(multiItemOrder);
      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(5)), equals('%PDF-'));
    });

    test('3. PDF generation handles an empty item list and null timestamp safely', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final emptyOrder = OrderModel(
        id: 'ord_empty',
        orderNumber: 'ORD-20260927-0000',
        representative: const {'id': 'r', 'name': 'Rep', 'email': 'r@med.com'},
        doctor: const {'id': 'd', 'name': 'Doc', 'specialization': 'General', 'phone': '123'},
        chemist: const {'id': 'c', 'name': 'Chemist', 'phone': '123', 'address': 'Main St'},
        items: const [],
        totalItems: 0,
        totalQuantity: 0,
        totalAmount: 0.0,
        status: 'pending',
        createdAt: null,
        updatedAt: null,
      );

      final bytes = await OrderPdfService.generateOrderPdf(emptyOrder);
      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(5)), equals('%PDF-'));
    });

    test('4. Currency formatting with showDecimals and Indian numbering', () {
      expect(formatCurrency(125450.0, showDecimals: true), '₹1,25,450.00');
      expect(formatCurrency(125450.0), '₹1,25,450');
      expect(formatCurrency(0.0, showDecimals: true), '₹0.00');
      expect(formatCurrency(48500.5, showDecimals: true), '₹48,500.50');
      expect(formatCurrency(500.0, showDecimals: true), '₹500.00');
    });

    test('5. Historical snapshot values are preserved and used', () {
      final historicalOrder = OrderModel(
        id: 'ord_hist',
        orderNumber: 'ORD-20260901-0001',
        representative: const {
          'id': 'rep_old',
          'name': 'Former Rep Name',
          'email': 'former@med.com',
        },
        doctor: const {
          'id': 'doc_old',
          'name': 'Dr. Retired',
          'specialization': 'Neurology',
          'phone': '1112223333',
        },
        chemist: const {
          'id': 'chm_old',
          'name': 'Relocated Chemist',
          'phone': '4445556666',
          'address': 'Old Market Road',
        },
        items: const [
          OrderItem(
            medicineId: 'med_old',
            medicineName: 'Discontinued Med',
            brand: 'Legacy Brand',
            composition: 'Old Formula',
            variantId: 'var_old',
            form: 'Capsule',
            strength: '250 mg',
            packSize: '30 caps',
            mrp: 120.0,
            supplierPrice: 100.0,
            quantity: 2,
            itemTotal: 200.0,
          ),
        ],
        totalItems: 1,
        totalQuantity: 2,
        totalAmount: 200.0,
        status: 'delivered',
        createdAt: DateTime(2026, 9, 1),
      );

      expect(historicalOrder.representativeName, 'Former Rep Name');
      expect(historicalOrder.doctorName, 'Dr. Retired');
      expect(historicalOrder.chemistName, 'Relocated Chemist');
      expect(historicalOrder.items.first.medicineName, 'Discontinued Med');
    });

    test('6. CompanyConfig default configuration values', () {
      expect(CompanyConfig.companyName, 'Medical Supplier');
      expect(CompanyConfig.documentTitle, 'Medicine Order');
    });

    testWidgets('7. RepresentativeOrderDetailsScreen renders Generate PDF button and action', (tester) async {
      final order = _createSampleOrder();
      final fakeOrderService = _FakeOrderService()..orders.add(order);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: MaterialApp(
            home: RepresentativeOrderDetailsScreen(
              orderId: order.id,
              initialOrder: order,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check AppBar action icon
      expect(find.byTooltip('Generate PDF'), findsOneWidget);

      // Check prominent button in body
      expect(find.widgetWithText(ElevatedButton, 'Generate PDF'), findsOneWidget);
    });

    testWidgets('8. AdminOrderDetailsScreen renders Generate PDF button and action', (tester) async {
      final order = _createSampleOrder();
      final fakeOrderService = _FakeOrderService()..orders.add(order);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
          ],
          child: MaterialApp(
            home: AdminOrderDetailsScreen(
              orderId: order.id,
              initialOrder: order,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check AppBar action icon
      expect(find.byTooltip('Generate PDF'), findsOneWidget);

      // Check prominent button in body
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Generate PDF'));
      expect(find.widgetWithText(OutlinedButton, 'Generate PDF'), findsOneWidget);
    });
  });

  group('Admin Reports & Analytics Tests', () {
    final fixedNow = DateTime(2026, 9, 27, 12, 0, 0);

    OrderModel makeTestOrder({
      required String id,
      required String orderNumber,
      required DateTime createdAt,
      String status = 'confirmed',
      String repId = 'rep_1',
      String repName = 'Rahul Sharma',
      String repEmail = 'rahul@med.com',
      String docId = 'doc_1',
      String docName = 'Dr. Gupta',
      String chmId = 'chm_1',
      String chmName = 'Apollo Bangalore',
      List<OrderItem>? items,
      double totalAmount = 1000.0,
      int totalItems = 1,
      int totalQuantity = 10,
    }) {
      return OrderModel(
        id: id,
        orderNumber: orderNumber,
        representative: {
          'id': repId,
          'name': repName,
          'email': repEmail,
        },
        doctor: {
          'id': docId,
          'name': docName,
          'specialization': 'General Physician',
          'phone': '9876543210',
        },
        chemist: {
          'id': chmId,
          'name': chmName,
          'phone': '9876543211',
          'address': 'MG Road, Bangalore',
        },
        items: items ??
            [
              OrderItem(
                medicineId: 'med_1',
                medicineName: 'Paracetamol',
                brand: 'HealthCorp',
                composition: 'PCM 500mg',
                variantId: 'var_1',
                form: 'Tablet',
                strength: '500 mg',
                packSize: '10x10',
                mrp: 120.0,
                supplierPrice: 100.0,
                quantity: totalQuantity,
                itemTotal: totalAmount,
              ),
            ],
        totalItems: totalItems,
        totalQuantity: totalQuantity,
        totalAmount: totalAmount,
        status: status,
        createdAt: createdAt,
        updatedAt: createdAt,
      );
    }

    test('1. Summary total orders', () {
      final orders = [
        makeTestOrder(id: '1', orderNumber: 'ORD-01', createdAt: fixedNow),
        makeTestOrder(id: '2', orderNumber: 'ORD-02', createdAt: fixedNow),
        makeTestOrder(id: '3', orderNumber: 'ORD-03', createdAt: fixedNow),
      ];
      final report = OrderReportService.generateReport(
        orders: orders,
        dateRange: const ReportDateRange.allTime(),
        referenceNow: fixedNow,
      );
      expect(report.statistics.totalOrders, 3);
    });

    test('2. Summary total order value', () {
      final orders = [
        makeTestOrder(id: '1', orderNumber: 'ORD-01', totalAmount: 1200.0, createdAt: fixedNow),
        makeTestOrder(id: '2', orderNumber: 'ORD-02', totalAmount: 800.0, createdAt: fixedNow),
      ];
      final report = OrderReportService.generateReport(
        orders: orders,
        dateRange: const ReportDateRange.allTime(),
        referenceNow: fixedNow,
      );
      expect(report.statistics.totalOrderValue, 2000.0);
    });

    test('3. Status breakdown', () {
      final orders = [
        makeTestOrder(id: '1', orderNumber: 'ORD-01', status: 'pending', totalAmount: 100.0, createdAt: fixedNow),
        makeTestOrder(id: '2', orderNumber: 'ORD-02', status: 'confirmed', totalAmount: 200.0, createdAt: fixedNow),
        makeTestOrder(id: '3', orderNumber: 'ORD-03', status: 'processing', totalAmount: 300.0, createdAt: fixedNow),
        makeTestOrder(id: '4', orderNumber: 'ORD-04', status: 'delivered', totalAmount: 400.0, createdAt: fixedNow),
        makeTestOrder(id: '5', orderNumber: 'ORD-05', status: 'cancelled', totalAmount: 50.0, createdAt: fixedNow),
      ];
      final report = OrderReportService.generateReport(
        orders: orders,
        dateRange: const ReportDateRange.allTime(),
        referenceNow: fixedNow,
      );
      expect(report.statusBreakdown.length, 5);

      final pendingItem = report.statusBreakdown.firstWhere((s) => s.status == 'pending');
      expect(pendingItem.count, 1);
      expect(pendingItem.percentage, 20.0);
      expect(pendingItem.totalValue, 100.0);

      final deliveredItem = report.statusBreakdown.firstWhere((s) => s.status == 'delivered');
      expect(deliveredItem.count, 1);
      expect(deliveredItem.percentage, 20.0);
      expect(deliveredItem.totalValue, 400.0);
    });

    test('4. Date range filtering', () {
      final orderWithDate = makeTestOrder(id: '1', orderNumber: 'ORD-01', createdAt: fixedNow);
      final orderWithoutDate = makeTestOrder(id: '2', orderNumber: 'ORD-02', createdAt: fixedNow);
      final orderNullDate = OrderModel(
        id: '3',
        orderNumber: 'ORD-03',
        representative: orderWithDate.representative,
        doctor: orderWithDate.doctor,
        chemist: orderWithDate.chemist,
        items: const [],
        totalItems: 0,
        totalQuantity: 0,
        totalAmount: 100.0,
        status: 'pending',
        createdAt: null,
      );

      final allReport = OrderReportService.generateReport(
        orders: [orderWithDate, orderWithoutDate, orderNullDate],
        dateRange: const ReportDateRange.allTime(),
        referenceNow: fixedNow,
      );
      expect(allReport.statistics.totalOrders, 3);

      final todayReport = OrderReportService.generateReport(
        orders: [orderWithDate, orderWithoutDate, orderNullDate],
        dateRange: const ReportDateRange.today(),
        referenceNow: fixedNow,
      );
      // Null date is excluded safely from today's range
      expect(todayReport.statistics.totalOrders, 2);
    });

    test('5. Today filtering', () {
      final todayOrder = makeTestOrder(id: '1', orderNumber: 'ORD-TODAY', createdAt: fixedNow);
      final yesterdayOrder = makeTestOrder(
        id: '2',
        orderNumber: 'ORD-YEST',
        createdAt: fixedNow.subtract(const Duration(days: 1)),
      );

      final report = OrderReportService.generateReport(
        orders: [todayOrder, yesterdayOrder],
        dateRange: const ReportDateRange.today(),
        referenceNow: fixedNow,
      );
      expect(report.statistics.totalOrders, 1);
      expect(report.filteredOrders.first.orderNumber, 'ORD-TODAY');
    });

    test('6. Last 7 days filtering', () {
      final day3Order = makeTestOrder(
        id: '1',
        orderNumber: 'ORD-DAY3',
        createdAt: fixedNow.subtract(const Duration(days: 3)),
      );
      final day10Order = makeTestOrder(
        id: '2',
        orderNumber: 'ORD-DAY10',
        createdAt: fixedNow.subtract(const Duration(days: 10)),
      );

      final report = OrderReportService.generateReport(
        orders: [day3Order, day10Order],
        dateRange: const ReportDateRange.last7Days(),
        referenceNow: fixedNow,
      );
      expect(report.statistics.totalOrders, 1);
      expect(report.filteredOrders.first.orderNumber, 'ORD-DAY3');
    });

    test('7. Last 30 days filtering', () {
      final day20Order = makeTestOrder(
        id: '1',
        orderNumber: 'ORD-DAY20',
        createdAt: fixedNow.subtract(const Duration(days: 20)),
      );
      final day40Order = makeTestOrder(
        id: '2',
        orderNumber: 'ORD-DAY40',
        createdAt: fixedNow.subtract(const Duration(days: 40)),
      );

      final report = OrderReportService.generateReport(
        orders: [day20Order, day40Order],
        dateRange: const ReportDateRange.last30Days(),
        referenceNow: fixedNow,
      );
      expect(report.statistics.totalOrders, 1);
      expect(report.filteredOrders.first.orderNumber, 'ORD-DAY20');
    });

    test('8. Custom date range', () {
      final orderAug = makeTestOrder(
        id: '1',
        orderNumber: 'ORD-AUG',
        createdAt: DateTime(2026, 8, 15),
      );
      final orderSep1 = makeTestOrder(
        id: '2',
        orderNumber: 'ORD-SEP01',
        createdAt: DateTime(2026, 9, 1),
      );
      final orderSep10 = makeTestOrder(
        id: '3',
        orderNumber: 'ORD-SEP10',
        createdAt: DateTime(2026, 9, 10),
      );
      final orderOct = makeTestOrder(
        id: '4',
        orderNumber: 'ORD-OCT',
        createdAt: DateTime(2026, 10, 1),
      );

      final report = OrderReportService.generateReport(
        orders: [orderAug, orderSep1, orderSep10, orderOct],
        dateRange: ReportDateRange.custom(
          startDate: DateTime(2026, 9, 1),
          endDate: DateTime(2026, 9, 15),
        ),
        referenceNow: fixedNow,
      );
      expect(report.statistics.totalOrders, 2);
      expect(report.filteredOrders.map((o) => o.orderNumber).toList(), ['ORD-SEP01', 'ORD-SEP10']);
    });

    test('9. Orders by representative', () {
      final orders = [
        makeTestOrder(id: '1', orderNumber: '1', repId: 'r1', repName: 'Rahul', totalAmount: 1000, createdAt: fixedNow),
        makeTestOrder(id: '2', orderNumber: '2', repId: 'r1', repName: 'Rahul', totalAmount: 1500, createdAt: fixedNow),
        makeTestOrder(id: '3', orderNumber: '3', repId: 'r2', repName: 'Priya', totalAmount: 5000, createdAt: fixedNow),
      ];

      final report = OrderReportService.generateReport(
        orders: orders,
        dateRange: const ReportDateRange.allTime(),
        referenceNow: fixedNow,
      );

      expect(report.representativeBreakdown.length, 2);
      // Rahul has 2 orders, Priya has 1 order -> Rahul is #1 by order count
      expect(report.representativeBreakdown[0].representativeName, 'Rahul');
      expect(report.representativeBreakdown[0].orderCount, 2);
      expect(report.representativeBreakdown[0].totalValue, 2500);

      expect(report.representativeBreakdown[1].representativeName, 'Priya');
      expect(report.representativeBreakdown[1].orderCount, 1);
      expect(report.representativeBreakdown[1].totalValue, 5000);
    });

    test('10. Top medicines calculation', () {
      const itemA = OrderItem(
        medicineId: 'm1',
        medicineName: 'Amoxicillin',
        brand: 'BrandA',
        composition: 'Amox 500',
        variantId: 'v1',
        form: 'Cap',
        strength: '500mg',
        packSize: '10',
        mrp: 100,
        supplierPrice: 80,
        quantity: 50,
        itemTotal: 4000,
      );
      const itemB = OrderItem(
        medicineId: 'm2',
        medicineName: 'Azithromycin',
        brand: 'BrandB',
        composition: 'Azith 250',
        variantId: 'v2',
        form: 'Tab',
        strength: '250mg',
        packSize: '6',
        mrp: 150,
        supplierPrice: 120,
        quantity: 10,
        itemTotal: 1200,
      );

      final o1 = makeTestOrder(id: '1', orderNumber: 'O1', items: [itemA, itemB], createdAt: fixedNow);
      final o2 = makeTestOrder(id: '2', orderNumber: 'O2', items: [itemA], createdAt: fixedNow);

      final report = OrderReportService.generateReport(
        orders: [o1, o2],
        dateRange: const ReportDateRange.allTime(),
        referenceNow: fixedNow,
      );

      expect(report.topMedicines.length, 2);
      // Amoxicillin has quantity 100, in 2 orders -> rank #1
      expect(report.topMedicines[0].medicineName, 'Amoxicillin');
      expect(report.topMedicines[0].totalQuantity, 100);
      expect(report.topMedicines[0].orderCount, 2);
      expect(report.topMedicines[0].totalValue, 8000);

      // Azithromycin has quantity 10, in 1 order -> rank #2
      expect(report.topMedicines[1].medicineName, 'Azithromycin');
      expect(report.topMedicines[1].totalQuantity, 10,);
      expect(report.topMedicines[1].orderCount, 1);
    });

    test('11. Top chemists calculation', () {
      final orders = [
        makeTestOrder(id: '1', orderNumber: '1', chmId: 'c1', chmName: 'Apollo', totalAmount: 2000, createdAt: fixedNow),
        makeTestOrder(id: '2', orderNumber: '2', chmId: 'c2', chmName: 'MedPlus', totalAmount: 8000, createdAt: fixedNow),
        makeTestOrder(id: '3', orderNumber: '3', chmId: 'c1', chmName: 'Apollo', totalAmount: 1000, createdAt: fixedNow),
      ];

      final report = OrderReportService.generateReport(
        orders: orders,
        dateRange: const ReportDateRange.allTime(),
        referenceNow: fixedNow,
      );

      expect(report.topChemists.length, 2);
      // MedPlus has 8000 total value -> rank #1 (sorted by totalValue descending)
      expect(report.topChemists[0].chemistName, 'MedPlus');
      expect(report.topChemists[0].totalValue, 8000);
      expect(report.topChemists[0].orderCount, 1);

      // Apollo has 3000 total value -> rank #2
      expect(report.topChemists[1].chemistName, 'Apollo');
      expect(report.topChemists[1].totalValue, 3000);
      expect(report.topChemists[1].orderCount, 2);
    });

    test('12. Order trend calculation', () {
      final orders = [
        makeTestOrder(id: '1', orderNumber: '1', createdAt: DateTime(2026, 9, 25), totalAmount: 500),
        makeTestOrder(id: '2', orderNumber: '2', createdAt: DateTime(2026, 9, 25), totalAmount: 500),
        makeTestOrder(id: '3', orderNumber: '3', createdAt: DateTime(2026, 9, 26), totalAmount: 1200),
      ];

      final report = OrderReportService.generateReport(
        orders: orders,
        dateRange: const ReportDateRange.last7Days(),
        referenceNow: fixedNow,
      );

      expect(report.orderTrend.length, 2);
      expect(report.orderTrend[0].orderCount, 2);
      expect(report.orderTrend[0].totalValue, 1000);
      expect(report.orderTrend[1].orderCount, 1);
      expect(report.orderTrend[1].totalValue, 1200);
    });

    testWidgets('13. Empty report displays friendly message', (tester) async {
      final fakeOrderService = _FakeOrderService();
      const admin = AppUser(
        uid: 'adm',
        name: 'Admin',
        email: 'adm@med.com',
        role: 'admin',
        phone: '123',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
            userProfileProvider.overrideWith((ref) => Stream.value(admin)),
          ],
          child: const MaterialApp(
            home: AdminReportsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Reports & Analytics'), findsOneWidget);
      expect(find.text('No orders found for this period.'), findsOneWidget);
      expect(find.text('View All Time'), findsOneWidget);
    });

    testWidgets('14. Representative cannot access admin reports through navigation/auth logic', (tester) async {
      final fakeOrderService = _FakeOrderService();
      const repUser = AppUser(
        uid: 'rep_123',
        name: 'Field Rep',
        email: 'rep@med.com',
        role: 'medical_rep',
        phone: '123',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
            userProfileProvider.overrideWith((ref) => Stream.value(repUser)),
          ],
          child: const MaterialApp(
            home: AdminReportsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Guard check: access denied rendered
      expect(find.text('Access Denied'), findsOneWidget);
      expect(
        find.text('Only administrators have access to Reports & Analytics.'),
        findsOneWidget,
      );
    });

    testWidgets('15. Existing dashboard functionality remains intact', (tester) async {
      final fakeOrderService = _FakeOrderService();
      const admin = AppUser(
        uid: 'adm_boss',
        name: 'Boss',
        email: 'boss@med.com',
        role: 'admin',
        phone: '123',
        active: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderServiceProvider.overrideWithValue(fakeOrderService),
            userProfileProvider.overrideWith((ref) => Stream.value(admin)),
            doctorsStreamProvider.overrideWith((ref) => Stream.value([])),
            chemistsStreamProvider.overrideWith((ref) => Stream.value([])),
            medicalRepsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(user: admin),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Welcome, Boss'), findsOneWidget);
      expect(find.text('Order Overview'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
    });
  });

  group('New Requirements & Custom Workflows Tests', () {
    testWidgets('AddMedicineScreen validates initial variant fields when variant is enabled',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddMedicineScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter medicine name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Medicine Name *'),
        'Amoxicillin',
      );

      // Try submitting without MRP (initial variant is enabled by default)
      final submitBtn =
          find.widgetWithText(ElevatedButton, 'Create Medicine & Variant');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter MRP'), findsOneWidget);

      // Enter MRP 50 and Supplier Price 60 (exceeds MRP)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'MRP (₹) *'),
        '50',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Supplier Price (₹) *'),
        '60',
      );
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Cannot exceed MRP'), findsOneWidget);
    });

    testWidgets('CreateOrderScreen Skip Doctor navigates to Chemist tab with Direct Order',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeDoctorsStreamProvider.overrideWith((ref) => Stream.value([])),
            activeChemistsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: CreateOrderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Skip Doctor
      await tester.tap(find.text('Skip Doctor'));
      await tester.pumpAndSettle();

      // Should show SnackBar message
      expect(
        find.text('Doctor skipped. Now select or enter a chemist.'),
        findsOneWidget,
      );

      // Should display Direct Order in status chip
      expect(find.text('Direct Order (No Doctor)'), findsOneWidget);
    });

    testWidgets('CreateOrderScreen Custom Doctor dialog sets custom doctor',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeDoctorsStreamProvider.overrideWith((ref) => Stream.value([])),
            activeChemistsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: CreateOrderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Custom Doctor
      await tester.tap(find.text('Custom Doctor'));
      await tester.pumpAndSettle();

      expect(find.text('Custom Doctor'), findsWidgets);
      expect(find.text('Use Doctor'), findsOneWidget);

      // Enter custom doctor name and submit dialog
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Doctor Name *'),
        'Dr. Custom Practitioner',
      );
      await tester.tap(find.text('Use Doctor'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Custom Practitioner'), findsWidgets);
    });

    testWidgets('CreateOrderScreen Custom Chemist dialog sets custom chemist',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeDoctorsStreamProvider.overrideWith((ref) => Stream.value([])),
            activeChemistsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: CreateOrderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Chemist tab
      await tester.tap(find.text('Select Chemist'));
      await tester.pumpAndSettle();

      // Tap Custom Chemist button
      await tester.tap(find.text('Chemist not in list? Enter Custom Chemist'));
      await tester.pumpAndSettle();

      expect(find.text('Custom Chemist'), findsWidgets);
      expect(find.text('Use Chemist'), findsOneWidget);

      // Enter chemist name and submit dialog
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Chemist Name *'),
        'Care Pharmacy',
      );
      await tester.tap(find.text('Use Chemist'));
      await tester.pumpAndSettle();

      expect(find.text('Care Pharmacy'), findsWidgets);
      expect(find.text('Custom Chemist Selected'), findsOneWidget);
    });

    testWidgets('OrderSuccessScreen renders Generate PDF, View My Orders, and Back to Home',
        (tester) async {
      final sampleOrder = _createSampleOrder();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: OrderSuccessScreen(order: sampleOrder),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all 3 required action buttons are present
      expect(find.text('Generate PDF'), findsOneWidget);
      expect(find.text('View My Orders'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);

      // Verify details
      expect(find.text('Order Submitted'), findsOneWidget);
      expect(find.text(sampleOrder.orderNumber), findsOneWidget);
    });
  });
}

OrderDraft _createSampleDraft() {
  return const OrderDraft(
    doctor: Doctor(
      id: 'doc_1',
      name: 'Dr. Test',
      specialization: 'Physician',
      phone: '9876543210',
      active: true,
    ),
    chemist: Chemist(
      id: 'chm_1',
      name: 'Test Pharmacy',
      phone: '9876543210',
      address: '123 Test St',
      active: true,
    ),
    items: [
      OrderDraftItem(
        medicineId: 'med_1',
        medicineName: 'Paracetamol',
        brand: 'Health',
        composition: 'PCM 500mg',
        variantId: 'var_1',
        form: 'Tablet',
        strength: '500 mg',
        packSize: '10 tablets',
        mrp: 60.0,
        supplierPrice: 50.0,
        quantity: 5,
      ),
    ],
  );
}

OrderModel _createSampleOrder({
  String id = 'ord_1',
  String orderNumber = 'ORD-20260926-0001',
  String repId = 'rep_current',
  String status = 'pending',
  double totalAmount = 250.0,
}) {
  return OrderModel(
    id: id,
    orderNumber: orderNumber,
    representative: {
      'id': repId,
      'name': 'Rahul Sharma',
      'email': 'rahul@example.com',
    },
    doctor: {
      'id': 'doc_1',
      'name': 'Dr. Test',
      'specialization': 'Physician',
      'phone': '9876543210',
    },
    chemist: {
      'id': 'chm_1',
      'name': 'Test Pharmacy',
      'phone': '9876543210',
      'address': '123 Test St',
    },
    items: const [
      OrderItem(
        medicineId: 'med_1',
        medicineName: 'Paracetamol',
        brand: 'Health',
        composition: 'PCM 500mg',
        variantId: 'var_1',
        form: 'Tablet',
        strength: '500 mg',
        packSize: '10 tablets',
        mrp: 60.0,
        supplierPrice: 50.0,
        quantity: 5,
        itemTotal: 250.0,
      ),
    ],
    totalItems: 1,
    totalQuantity: 5,
    totalAmount: totalAmount,
    status: status,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

class _FakeOrderService extends OrderService {
  final List<OrderModel> orders = [];
  bool shouldFail = false;
  Completer<OrderModel>? submitCompleter;
  int submissionAttempts = 0;

  @override
  Future<String> generateOrderNumber() async {
    return 'ORD-20260926-0001';
  }

  @override
  Future<OrderModel> createOrder({
    required OrderDraft draft,
    AppUser? representativeProfile,
  }) async {
    submissionAttempts++;
    if (submitCompleter != null) {
      return submitCompleter!.future;
    }
    if (shouldFail) {
      throw Exception('Network error');
    }
    final order = OrderModel(
      id: 'ORDER_123',
      orderNumber: 'ORD-20260926-0001',
      representative: {
        'id': 'rep_uid',
        'name': 'Rahul Sharma',
        'email': 'rahul@example.com',
      },
      doctor: {
        'id': draft.doctorId,
        'name': draft.doctorName,
        'specialization': draft.doctorSpecialization,
        'phone': draft.doctorPhone,
      },
      chemist: {
        'id': draft.chemistId,
        'name': draft.chemistName,
        'phone': draft.chemistPhone,
        'address': draft.chemistAddress,
      },
      items: draft.items.map((i) => OrderItem.fromDraftItem(i)).toList(),
      totalItems: draft.totalItems,
      totalQuantity: draft.totalQuantity,
      totalAmount: draft.totalAmount,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    orders.add(order);
    return order;
  }

  @override
  Stream<List<OrderModel>> watchMyOrders(String representativeId) {
    return Stream.value(
      orders.where((o) => o.representativeId == representativeId).toList(),
    );
  }

  @override
  Stream<OrderModel?> watchOrder(String orderId) {
    try {
      final order = orders.firstWhere((o) => o.id == orderId);
      return Stream.value(order);
    } catch (_) {
      return Stream.value(null);
    }
  }

  @override
  Stream<List<OrderModel>> watchAllOrders() {
    return Stream.value(List<OrderModel>.from(orders));
  }

  String? lastUpdatedOrderId;
  String? lastUpdatedStatus;

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    lastUpdatedOrderId = orderId;
    lastUpdatedStatus = status;
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final old = orders[index];
      orders[index] = OrderModel(
        id: old.id,
        orderNumber: old.orderNumber,
        representative: old.representative,
        doctor: old.doctor,
        chemist: old.chemist,
        items: old.items,
        totalItems: old.totalItems,
        totalQuantity: old.totalQuantity,
        totalAmount: old.totalAmount,
        status: status,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}

class _MockUserWithUid extends Fake implements User {
  final String _uid;
  _MockUserWithUid(this._uid);

  @override
  String get uid => _uid;

  @override
  String? get email => 'test@med.com';
}

class _MockUser extends Fake implements User {
  @override
  String get uid => 'mock_uid';

  @override
  String? get email => 'test@med.com';
}

