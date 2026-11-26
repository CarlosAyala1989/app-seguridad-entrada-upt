import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/core/network/http_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('las peticiones con credenciales no siguen redirecciones', () async {
    final client = MockClient((request) async {
      expect(
        request.url.toString(),
        'https://api.upt.pe/api/autenticacion/sesion',
      );
      expect(request.headers['Authorization'], 'Bearer prueba');
      expect(request.followRedirects, isFalse);
      return http.Response(
        '',
        302,
        headers: {'location': 'https://otro.example.org'},
      );
    });
    addTearDown(client.close);
    final gateway = ApiHttpGateway(
      baseUrl: 'https://api.upt.pe/api/',
      client: client,
    );
    final response = await gateway.get(
      '/autenticacion/sesion',
      headers: {'Authorization': 'Bearer prueba'},
    );
    expect(response.esExitosa, isFalse);
  });

  test('rechaza URL con credenciales antes de enviar una solicitud', () async {
    var llamadas = 0;
    final client = MockClient((_) async {
      llamadas++;
      return http.Response('{}', 200);
    });
    addTearDown(client.close);
    final gateway = ApiHttpGateway(
      baseUrl: 'https://usuario:clave@api.upt.pe/api',
      client: client,
    );
    await expectLater(gateway.get('/sesion'), throwsA(isA<NetworkFailure>()));
    expect(llamadas, 0);
  });
}
