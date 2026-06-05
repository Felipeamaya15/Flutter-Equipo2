import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SolicitudesProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> _solicitudes = [];
  bool _isLoading = true;
  String? _error;

  QueryDocumentSnapshot? _solicitudSeleccionada;

  List<QueryDocumentSnapshot> get solicitudes => _solicitudes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  QueryDocumentSnapshot? get solicitudSeleccionada => _solicitudSeleccionada;

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