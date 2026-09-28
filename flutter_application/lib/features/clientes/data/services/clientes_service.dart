import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/cliente.dart';

class ClientesService {
  final _client = ApiClient.instance.dio;

  Future<PagedClientes> getClientes({int page = 1, int limit = 10}) async {
    final response = await _client.get(
      ApiEndpoints.clientes,
      queryParameters: {'page': page, 'limit': limit},
    );
    return PagedClientes.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TipoCliente>> getTipos() async {
    final response = await _client.get(ApiEndpoints.tiposCliente);
    return (response.data as List<dynamic>)
        .map((item) => TipoCliente.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> crearCliente(String nombre, int telefono, int tipo) async {
    await _client.post(ApiEndpoints.clientes, data: {
      'nombre': nombre,
      'telefono': telefono,
      'idTipoCliente': tipo,
    });
  }

  Future<void> actualizarCliente(
      int id, String nombre, int telefono, int tipo) async {
    await _client.patch('${ApiEndpoints.clientes}/$id', data: {
      'nombre': nombre,
      'telefono': telefono,
      'idTipoCliente': tipo,
    });
  }

  Future<void> eliminarCliente(int id) async {
    await _client.delete('${ApiEndpoints.clientes}/$id');
  }

  Future<void> crearTipo(String descripcion) async {
    await _client
        .post(ApiEndpoints.tiposCliente, data: {'descripcion': descripcion});
  }

  Future<void> actualizarTipo(int id, String descripcion) async {
    await _client.patch('${ApiEndpoints.tiposCliente}/$id',
        data: {'descripcion': descripcion});
  }

  Future<void> eliminarTipo(int id) async {
    await _client.delete('${ApiEndpoints.tiposCliente}/$id');
  }
}
