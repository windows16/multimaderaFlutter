import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cliente.dart';
import '../data/services/clientes_service.dart';

final clientesServiceProvider =
    Provider<ClientesService>((ref) => ClientesService());

final clientesProvider =
    StateNotifierProvider<ClientesNotifier, ClientesState>((ref) {
  return ClientesNotifier(ref.read(clientesServiceProvider))..cargar();
});

class ClientesState {
  const ClientesState({
    this.clientes = const [],
    this.tipos = const [],
    this.loading = false,
    this.error,
    this.page = 1,
    this.totalPages = 1,
  });

  final List<Cliente> clientes;
  final List<TipoCliente> tipos;
  final bool loading;
  final String? error;
  final int page;
  final int totalPages;

  ClientesState copyWith({
    List<Cliente>? clientes,
    List<TipoCliente>? tipos,
    bool? loading,
    String? error,
    int? page,
    int? totalPages,
    bool clearError = false,
  }) =>
      ClientesState(
        clientes: clientes ?? this.clientes,
        tipos: tipos ?? this.tipos,
        loading: loading ?? this.loading,
        error: clearError ? null : error ?? this.error,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
      );
}

class ClientesNotifier extends StateNotifier<ClientesState> {
  ClientesNotifier(this._service) : super(const ClientesState());
  final ClientesService _service;

  Future<void> cargar({int page = 1}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await Future.wait([
        _service.getClientes(page: page),
        _service.getTipos(),
      ]);
      final clientes = result[0] as PagedClientes;
      state = state.copyWith(
        clientes: clientes.data,
        tipos: result[1] as List<TipoCliente>,
        page: page,
        totalPages: clientes.totalPages,
        loading: false,
      );
    } catch (error) {
      state = state.copyWith(loading: false, error: _message(error));
    }
  }

  Future<void> ejecutar(Future<void> Function() action) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await action();
      await cargar(page: state.page);
    } catch (error) {
      state = state.copyWith(loading: false, error: _message(error));
    }
  }

  String _message(Object error) => 'No se pudo completar la operación: $error';
}
