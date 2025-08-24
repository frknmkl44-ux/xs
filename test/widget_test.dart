// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:msn_kurye/giris_ekrani.dart';

void main() {
  testWidgets('Splash screen is displayed', (WidgetTester tester) async {
    // Initialize Firebase for testing
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Verify that the splash screen is displayed
    expect(find.byType(SplashScreen), findsOneWidget);
    
    // Advance time to allow the splash screen to complete its animation
    await tester.pumpAndSettle(const Duration(seconds: 4));
    
    // Verify that we've navigated to the role selection page
    expect(find.byType(RoleSelectionPage), findsOneWidget);
  });
}
