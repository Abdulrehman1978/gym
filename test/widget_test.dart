import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ironlog/app.dart';

void main() {
  testWidgets('App loads with IronLog title', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: IronLogApp()));
    expect(find.text('IronLog'), findsOneWidget);
  });
}
