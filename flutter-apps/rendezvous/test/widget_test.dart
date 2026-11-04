import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous/main.dart';

void main() {
  testWidgets('Les prestations s’affichent', (tester) async {
    await tester.pumpWidget(const RendezVousApp());
    expect(find.text('Coupe'), findsOneWidget);
  });
}
