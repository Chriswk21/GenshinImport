import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:genshin_import/main.dart';
import 'package:genshin_import/providers/auth_provider.dart';
import 'package:genshin_import/providers/cart_provider.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const GenshinImportApp(),
      ),
    );
  });
}
