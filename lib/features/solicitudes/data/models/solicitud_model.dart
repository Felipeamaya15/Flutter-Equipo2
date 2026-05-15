import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/solicitud.dart';

class SolicitudModel extends Solicitud {
  const SolicitudModel({
    required super.id,
    required super.email,
    required super.phone,
    required super.fechaEvento,
    required super.estado,
    required super.fechaCreacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'fecha_evento': Timestamp.fromDate(fechaEvento),
      'estado': estado,
      'creado_en': Timestamp.fromDate(fechaCreacion),
    };
  }

  factory SolicitudModel.fromEntity(Solicitud solicitud) {
    return SolicitudModel(
      id: solicitud.id,
      email: solicitud.email,
      phone: solicitud.phone,
      fechaEvento: solicitud.fechaEvento,
      estado: solicitud.estado,
      fechaCreacion: solicitud.fechaCreacion,
    );
  }
}