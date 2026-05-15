class Solicitud {
  final String id;
  final String email;
  final String phone;
  final DateTime fechaEvento;
  final String estado;
  final DateTime fechaCreacion;

  const Solicitud({
    required this.id,
    required this.email,
    required this.phone,
    required this.fechaEvento,
    required this.estado,
    required this.fechaCreacion,
  });
}