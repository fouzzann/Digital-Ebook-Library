import 'package:digital_ebook_library/core/services/service_locator.dart';
import 'package:digital_ebook_library/features/ebooks/presentation/bloc/ebook_bloc.dart';
import 'package:digital_ebook_library/features/ebooks/presentation/pages/upload_ebook_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await initServiceLocator();
  });

  testWidgets('UploadEbookPage renders PDF file selector and format options', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: sl<EbookBloc>(),
          child: const UploadEbookPage(),
        ),
      ),
    );

    // Verify Title & Header
    expect(find.text('Index New E-Book'), findsOneWidget);

    // Verify File Selector Zone
    expect(find.text('Select PDF or E-Book File'), findsOneWidget);
    expect(find.text('PDF (Default)'), findsOneWidget);

    // Verify Form Fields
    expect(find.text('Book Title'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
  });
}
