class Cliente {
  const Cliente({
    required this.nombre,
    required this.telefono,
    required this.idTipoCliente,
    required this.numeroDeCliente,
    this.tipoCliente,
  });

  final String nombre;
  final int telefono;
  final int idTipoCliente;
  final int numeroDeCliente;
  final String? tipoCliente;

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        nombre: json['nombre'] as String,
        telefono: int.parse(json['telefono'].toString()),
        idTipoCliente: int.parse(json['idTipoCliente'].toString()),
        numeroDeCliente: int.parse(json['numeroDeCliente'].toString()),
        tipoCliente: json['tipoCliente'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'telefono': telefono,
        'idTipoCliente': idTipoCliente,
      };
}

class TipoCliente {
  const TipoCliente({required this.descripcion, required this.idTipoCliente});

  final String descripcion;
  final int idTipoCliente;

  factory TipoCliente.fromJson(Map<String, dynamic> json) => TipoCliente(
        descripcion: json['descripcion'] as String,
        idTipoCliente: int.parse(json['idTipoCliente'].toString()),
      );

  Map<String, dynamic> toJson() => {'descripcion': descripcion};
}

class PagedClientes {
  const PagedClientes({required this.data, required this.totalPages});

  final List<Cliente> data;
  final int totalPages;

  factory PagedClientes.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>;
    return PagedClientes(
      data: (json['data'] as List<dynamic>)
          .map((item) => Cliente.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPages: int.parse(meta['totalPages'].toString()),
    );
  }
}
