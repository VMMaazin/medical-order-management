import 'package:flutter_test/flutter_test.dart';
import 'package:medical_order_management/main.dart';

void main() {
  testWidgets('App renders placeholder screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const MedicalOrderManagementApp());

    expect(find.text('Medical Order Management'), findsOneWidget);
    expect(find.text('Firebase setup pending'), findsOneWidget);
  });
}
