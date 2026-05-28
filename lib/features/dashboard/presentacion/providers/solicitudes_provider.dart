import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SolicitudesProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> _solicitudes = [];
  bool _isLoading = true;
  String? _error;

  List<QueryDocumentSnapshot> get solicitudes => _solicitudes;
  bool get isLoading => _isLoading;
  String? get error => _error;

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