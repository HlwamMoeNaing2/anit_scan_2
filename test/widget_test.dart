import 'package:anit_scan_2/app/anit_scan_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the shell starts on the root route', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AnitScanApp()));
    await tester.pump();

    expect(find.text('Anit Scan 2'), findsOneWidget);
  });
}
