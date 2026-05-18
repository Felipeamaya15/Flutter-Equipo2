class Cotizacion {
  final String id;
  final String emailCliente;
  final String telefonoCliente;
  final DateTime fechaEvento;
  final String estado;
  final String usuarioAsignado;
  final String nombreEvento;

  Cotizacion({
    required this.id,
    required this.emailCliente,
    required this.telefonoCliente,
    required this.fechaEvento,
    required this.estado,
    required this.usuarioAsignado,
    required this.nombreEvento,
  });

  Map<String, dynamic> toFirestoreMap() {
    return {
      'emailCliente': emailCliente,
      'telefonoCliente': telefonoCliente,
      'fechaEvento': fechaEvento,
      'estado': estado,
      'usuarioAsignado': usuarioAsignado,
      'nombreEvento': nombreEvento,
    };
  }
}