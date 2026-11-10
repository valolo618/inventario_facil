import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_facil/main.dart';

void main() {
  testWidgets('La aplicación Inventario Fácil se inicia', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InventarioFacilApp());

    expect(find.text('Inventario Fácil'), findsOneWidget);
    expect(find.text('Mis productos'), findsOneWidget);
  });
}