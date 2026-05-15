import '../../domain/entities/solicitud.dart';
import '../../domain/repositories/solicitud_repository.dart';
import '../datasources/solicitud_remote_datasource.dart';
import '../models/solicitud_model.dart';

class SolicitudRepositoryImpl implements SolicitudRepository {
  final SolicitudRemoteDatasource datasource;

  SolicitudRepositoryImpl({
    required this.datasource,
  });

  @override
  Future<String> crearSolicitud(Solicitud solicitud) {
    final model = SolicitudModel.fromEntity(solicitud);
    return datasource.crearSolicitud(model);
  }
}