import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SolicitudesProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> _solicitudes = [];
  bool _isLoading = true;
  String? _error;

  QueryDocumentSnapshot? _solicitudSeleccionada;

  bool _ocultarCompletadas = true;

  List<QueryDocumentSnapshot> get solicitudes => _solicitudes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  QueryDocumentSnapshot? get solicitudSeleccionada => _solicitudSeleccionada;

  bool get ocultarCompletadas => _ocultarCompletadas;

  List<QueryDocumentSnapshot> get solicitudesFiltradas {
    if (_ocultarCompletadas) {
      return _solicitudes.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final String estado = (data['estado'] ?? 'Pendiente').toString().trim().toLowerCase();
        // Remueve automáticamente de la vista las que están completadas
        return estado != 'completado';
      }).toList();
    }
    return _solicitudes;
  }

  List<QueryDocumentSnapshot> get solicitudesCompletadas {
    return _solicitudes.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final String estado = (data['estado'] ?? '').toString().trim().toLowerCase();
      return estado == 'completado';
    }).toList();
  }

  void toggleFiltroCompletadas(bool valor) {
    _ocultarCompletadas = valor;
    notifyListeners();
  }

  SolicitudesProvider() {
    _initStream();
  }

  void _initStream() {
    FirebaseFirestore.instance.collection('solicitudes').snapshots().listen(
      (snapshot) {
        _solicitudes = snapshot.docs;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      }
    );
  }

  void seleccionarSolicitud(QueryDocumentSnapshot? doc) {
    _solicitudSeleccionada = doc;
    notifyListeners();
  }

  void clearSeleccion() {
    _solicitudSeleccionada = null;
    notifyListeners();
  }

  Future<void> actualizarEstado(String docId, String nuevoEstado) async {
    try {
      await FirebaseFirestore.instance.collection('solicitudes').doc(docId).update({'estado': nuevoEstado});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> tomarSolicitud(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('solicitudes').doc(docId).update({
        'usuarioAsignado': 'Coordinador General',
        'estado': 'En proceso'
      });
    } catch (e) {
      rethrow;
    }
  }
}