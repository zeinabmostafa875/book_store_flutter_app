import 'package:flutter_test/flutter_test.dart';

import 'package:book_app/main.dart';

void main() {
  testWidgets('Login screen renders', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BookApp());

    // Verify that the login screen is displayed
    expect(find.text('Login'), findsOneWidget);
  });
}
