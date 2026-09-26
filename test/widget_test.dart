import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_order_management/models/app_user.dart';
import 'package:medical_order_management/providers/auth_provider.dart';
import 'package:medical_order_management/screens/admin/admin_dashboard_screen.dart';
import 'package:medical_order_management/screens/admin/admin_management_screen.dart';
import 'package:medical_order_management/screens/admin/admin_orders_screen.dart';
import 'package:medical_order_management/screens/admin/admin_profile_screen.dart';
import 'package:medical_order_management/screens/admin/placeholder_screen.dart';
import 'package:medical_order_management/screens/auth/auth_wrapper.dart';
import 'package:medical_order_management/screens/auth/login_screen.dart';
import 'package:medical_order_management/screens/representative/representative_dashboard_screen.dart';

void main() {
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

    testWidgets('tapping a dashboard card opens PlaceholderScreen with Coming Soon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardScreen(user: adminUser),
          ),
        ),
      );

      await tester.tap(find.text('Medicines'));
      await tester.pumpAndSettle();

      expect(find.byType(PlaceholderScreen), findsOneWidget);
      expect(find.text('Coming Soon'), findsOneWidget);
      expect(find.text('Medicines'), findsNWidgets(2)); // AppBar & body title
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
