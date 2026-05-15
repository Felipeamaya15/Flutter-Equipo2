import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../models/solicitud_model.dart';

class SolicitudRemoteDatasource {
  final FirebaseFirestore firestore;

  SolicitudRemoteDatasource({
    required this.firestore,
  });

  Future<String> crearSolicitud(SolicitudModel solicitud) async {
    await firestore
        .collection(FirebaseCollections.solicitudes)
        .doc(solicitud.id)
        .set(solicitud.toMap());

    return solicitud.id;
  }
}