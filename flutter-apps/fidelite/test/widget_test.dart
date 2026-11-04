import 'package:flutter_test/flutter_test.dart';
import 'package:fidelite/main.dart';

void main() {
  testWidgets('La carte s’affiche', (tester) async {
    await tester.pumpWidget(const FideliteApp());
    expect(find.text('CARTE DE FIDÉLITÉ'), findsOneWidget);
  });
}
