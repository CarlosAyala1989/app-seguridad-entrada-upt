import 'package:flutter_camera_smoke/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra un mensaje cuando no hay cámara disponible', (
    tester,
  ) async {
    await tester.pumpWidget(const CameraSmokeApp(cameras: []));
    await tester.pump();

    expect(find.text('No se detectó una cámara disponible.'), findsOneWidget);
  });
}
