import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadeer_app/app.dart';
import 'package:hadeer_app/features/auth/auth_providers.dart';

void main() {
  testWidgets('Unauthenticated session shows school login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith((ref) => Stream.value(false))],
        child: const HadeerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Masuk →'), findsOneWidget);
    expect(find.text('Email sekolah'), findsOneWidget);
    expect(find.text('Kata sandi'), findsOneWidget);
  });
  testWidgets('Startup failure blocks login until Firebase is configured', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: HadeerApp(startupError: StateError('Missing native configuration'))),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Firebase belum terhubung'), findsOneWidget);
    expect(find.text('Masuk →'), findsNothing);
  });
}
