import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/features/clientes/data/models/cliente.dart';

void main() {
  test('Cliente serializa los campos que acepta la API', () {
    const cliente = Cliente(
      nombre: 'Juan Carlos',
      telefono: 12345678,
      idTipoCliente: 2,
      numeroDeCliente: 10,
      tipoCliente: 'Propietario',
    );

    expect(cliente.toJson(), {
      'nombre': 'Juan Carlos',
      'telefono': 12345678,
      'idTipoCliente': 2,
    });
  });

  test('Cliente interpreta la respuesta paginada de la API', () {
    final response = PagedClientes.fromJson({
      'data': [
        {
          'nombre': 'Ana',
          'telefono': 87654321,
          'idTipoCliente': 1,
          'numeroDeCliente': 3,
          'tipoCliente': 'Empresa',
        },
      ],
      'meta': {'totalPages': 1},
    });

    expect(response.data.single.nombre, 'Ana');
    expect(response.totalPages, 1);
  });
}
