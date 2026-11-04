import 'package:flutter_test/flutter_test.dart';
import 'package:voyageurs/main.dart';

void main() {
  testWidgets('Les arrêts favoris s’affichent', (tester) async {
    await tester.pumpWidget(const VoyageursApp());
    expect(find.text('Gare SNCF'), findsOneWidget);
  });
}
