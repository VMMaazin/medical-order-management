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
import 'package:medical_order_management/providers/auth_provider.dart';
import 'package:medical_order_management/providers/chemist_provider.dart';
import 'package:medical_order_management/providers/doctor_provider.dart';
import 'package:medical_order_management/providers/medical_rep_provider.dart';
import 'package:medical_order_management/providers/medicine_provider.dart';
import 'package:medical_order_management/screens/admin/admin_dashboard_screen.dart';
import 'package:medical_order_management/screens/admin/admin_management_screen.dart';
import 'package:medical_order_management/screens/admin/admin_orders_screen.dart';
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
import 'package:medical_order_management/screens/admin/placeholder_screen.dart';
import 'package:medical_order_management/screens/auth/auth_wrapper.dart';
import 'package:medical_order_management/screens/auth/login_screen.dart';
import 'package:medical_order_management/screens/representative/representative_dashboard_screen.dart';

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

    testWidgets('tapping Reports card opens PlaceholderScreen with Coming Soon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardScreen(user: adminUser),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Reports'));
      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();

      expect(find.byType(PlaceholderScreen), findsOneWidget);
      expect(find.text('Coming Soon'), findsOneWidget);
      expect(find.text('Reports'), findsNWidgets(2)); // AppBar & body title
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
      expect(find.text('Coming Soon'), findsOneWidget);

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

    testWidgets('AddMedicineScreen validates required form fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddMedicineScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Create & Add Variants'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter medicine name'), findsOneWidget);
      expect(find.text('Please enter brand/manufacturer name'), findsOneWidget);
      expect(find.text('Please enter active composition'), findsOneWidget);
      expect(find.text('Please enter therapeutic category'), findsOneWidget);
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
      expect(find.text('Please enter doctor specialization'), findsOneWidget);

      // Enter invalid phone number
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Doctor Name *'),
        'Dr. Test',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Specialization *'),
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
      expect(find.text('Please enter phone number'), findsOneWidget);
      expect(find.text('Please enter address'), findsOneWidget);

      // Enter invalid phone number
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Chemist / Shop Name *'),
        'Apollo Pharmacy',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Address *'),
        '123 MG Road',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number *'),
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
        find.widgetWithText(TextFormField, 'Phone Number *'),
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
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Representative'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter representative name'), findsOneWidget);
      expect(find.text('Please enter email address'), findsOneWidget);
      expect(find.text('Please enter phone number'), findsOneWidget);

      // Enter invalid email and invalid phone
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

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Representative'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(
        find.text('Please enter a valid 10-digit Indian phone number'),
        findsOneWidget,
      );

      // Clear name so form does not submit to remote service
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name *'),
        '',
      );

      // Enter valid email and valid 10-digit phone
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address *'),
        'valid.rep@med.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number *'),
        '9876543210',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Representative'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsNothing);
      expect(
        find.text('Please enter a valid 10-digit Indian phone number'),
        findsNothing,
      );
      expect(find.text('Please enter representative name'), findsOneWidget);
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
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Deactivate'), findsOneWidget);
    });
  });

  group('Representative Dashboard Tests', () {
    testWidgets(
        'RepresentativeDashboardScreen displays required texts and logout button',
        (WidgetTester tester) async {
      const repUser = AppUser(
        uid: 'rep_123',
        name: 'John Representative',
        email: 'rep@medicalorder.com',
        role: 'medical_rep',
        phone: '+919876543211',
        active: true,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RepresentativeDashboardScreen(user: repUser),
          ),
        ),
      );

      expect(find.text('Medical Representative Dashboard'),
          findsNWidgets(2)); // AppBar and Body
      expect(find.text('Logged in as Medical Representative'), findsOneWidget);
      expect(find.text('John Representative'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
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
      expect(find.text('Medical Representative Dashboard'), findsNWidgets(2));
      expect(find.text('Logged in as Medical Representative'), findsOneWidget);
    });
  });
}

class _MockUser extends Fake implements User {
  @override
  String get uid => 'mock_uid';

  @override
  String? get email => 'test@med.com';
}
