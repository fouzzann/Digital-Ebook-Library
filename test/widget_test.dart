import 'package:digital_ebook_library/core/services/service_locator.dart';
import 'package:digital_ebook_library/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('E-book library app renders main page with title', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await initServiceLocator();

    // Build app and trigger frame
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 700));

    // Verify main app title is rendered
    expect(find.text('Digital E Book'), findsOneWidget);
  });
}
