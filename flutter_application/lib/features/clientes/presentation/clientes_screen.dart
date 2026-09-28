import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cliente.dart';
import 'clientes_provider.dart';

class ClientesScreen extends ConsumerStatefulWidget {
  const ClientesScreen({super.key});

  @override
  ConsumerState<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends ConsumerState<ClientesScreen> {
  final _searchController = TextEditingController();
  int _tab = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientesProvider);
    final query = _searchController.text.toLowerCase();
    final clientes = state.clientes
        .where((item) =>
            item.nombre.toLowerCase().contains(query) ||
            item.telefono.toString().contains(query))
        .toList();
    final tipos = state.tipos
        .where((item) => item.descripcion.toLowerCase().contains(query))
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clientes'),
          bottom: TabBar(
            isScrollable: true,
            onTap: (value) => setState(() => _tab = value),
            tabs: const [
              Tab(text: 'Clientes'),
              Tab(text: 'Tipos de cliente'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: _tab == 0
                      ? 'Buscar por nombre o teléfono'
                      : 'Buscar por descripción',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpiar búsqueda',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (state.error != null)
              MaterialBanner(
                content: Text(state.error!),
                actions: [
                  TextButton(
                    onPressed: () =>
                        ref.read(clientesProvider.notifier).cargar(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            Expanded(
              child: state.loading && state.clientes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _tab == 0
                      ? _clientesList(clientes)
                      : _tiposList(tipos),
            ),
            if (_tab == 0 && state.totalPages > 1) _pagination(state),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              _tab == 0 ? _editarCliente(context) : _editarTipo(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _clientesList(List<Cliente> clientes) {
    if (clientes.isEmpty) return const Center(child: Text('No hay clientes.'));
    return RefreshIndicator(
      onRefresh: () => ref.read(clientesProvider.notifier).cargar(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: clientes.length,
        itemBuilder: (context, index) {
          final cliente = clientes[index];
          return Card(
            child: ListTile(
              leading:
                  CircleAvatar(child: Text(cliente.nombre[0].toUpperCase())),
              title: Text(cliente.nombre),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text('${cliente.telefono}'),
                    ],
                  ),
                  Text(
                    '${cliente.tipoCliente ?? cliente.idTipoCliente}',
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _editarCliente(context, cliente);
                  if (value == 'delete') _eliminarCliente(cliente);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tiposList(List<TipoCliente> tipos) {
    if (tipos.isEmpty) {
      return const Center(child: Text('No hay tipos de cliente.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tipos.length,
      itemBuilder: (context, index) {
        final tipo = tipos[index];
        return Card(
          child: ListTile(
            title: Text(tipo.descripcion),
            leading: CircleAvatar(child: Text('${tipo.idTipoCliente}')),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _editarTipo(context, tipo);
                if (value == 'delete') _eliminarTipo(tipo);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pagination(ClientesState state) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: state.page > 1
                  ? () => ref
                      .read(clientesProvider.notifier)
                      .cargar(page: state.page - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text('${state.page} / ${state.totalPages}'),
            IconButton(
              onPressed: state.page < state.totalPages
                  ? () => ref
                      .read(clientesProvider.notifier)
                      .cargar(page: state.page + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      );

  Future<void> _editarCliente(BuildContext context, [Cliente? cliente]) async {
    final nombre = TextEditingController(text: cliente?.nombre ?? '');
    final telefono =
        TextEditingController(text: cliente?.telefono.toString() ?? '');
    final tipos = ref.read(clientesProvider).tipos;
    var tipo = cliente?.idTipoCliente ??
        (tipos.isEmpty ? null : tipos.first.idTipoCliente);
    if (tipo == null) {
      _mostrarMensaje('Crea un tipo de cliente antes de registrar clientes.');
      return;
    }
    final guardado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cliente == null ? 'Nuevo cliente' : 'Editar cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nombre,
                decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(
              controller: telefono,
              keyboardType: TextInputType.phone,
              decoration:
                  const InputDecoration(labelText: 'Teléfono (8 dígitos)'),
            ),
            DropdownButtonFormField<int>(
              value: tipo,
              decoration: const InputDecoration(labelText: 'Tipo de cliente'),
              items: tipos
                  .map((item) => DropdownMenuItem(
                      value: item.idTipoCliente, child: Text(item.descripcion)))
                  .toList(),
              onChanged: (value) => tipo = value,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (guardado != true) return;
    final numero = int.tryParse(telefono.text);
    if (nombre.text.trim().isEmpty ||
        numero == null ||
        telefono.text.length != 8) {
      _mostrarMensaje('Ingresa un nombre y un teléfono válido de 8 dígitos.');
      return;
    }
    final service = ref.read(clientesServiceProvider);
    final notifier = ref.read(clientesProvider.notifier);
    await notifier.ejecutar(() => cliente == null
        ? service.crearCliente(nombre.text.trim(), numero, tipo!)
        : service.actualizarCliente(
            cliente.numeroDeCliente, nombre.text.trim(), numero, tipo!));
  }

  Future<void> _editarTipo(BuildContext context, [TipoCliente? tipo]) async {
    final descripcion = TextEditingController(text: tipo?.descripcion ?? '');
    final guardado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            tipo == null ? 'Nuevo tipo de cliente' : 'Editar tipo de cliente'),
        content: TextField(
          controller: descripcion,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Descripción'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (guardado != true || descripcion.text.trim().isEmpty) return;
    final service = ref.read(clientesServiceProvider);
    final notifier = ref.read(clientesProvider.notifier);
    await notifier.ejecutar(() => tipo == null
        ? service.crearTipo(descripcion.text.trim())
        : service.actualizarTipo(tipo.idTipoCliente, descripcion.text.trim()));
  }

  Future<void> _eliminarCliente(Cliente cliente) async {
    if (!await _confirmar('¿Deseas eliminar a ${cliente.nombre}?')) return;
    await ref.read(clientesProvider.notifier).ejecutar(() => ref
        .read(clientesServiceProvider)
        .eliminarCliente(cliente.numeroDeCliente));
  }

  Future<void> _eliminarTipo(TipoCliente tipo) async {
    if (!await _confirmar('¿Deseas eliminar ${tipo.descripcion}?')) return;
    await ref.read(clientesProvider.notifier).ejecutar(() =>
        ref.read(clientesServiceProvider).eliminarTipo(tipo.idTipoCliente));
  }

  Future<bool> _confirmar(String mensaje) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(mensaje),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar')),
          ],
        ),
      ) ??
      false;

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }
}
