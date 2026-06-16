import 'dart:async'; // NUEVO: Para poder apagar la conexión
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // NUEVO: Para escuchar las sesiones

class SolicitudesProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> _solicitudes = [];
  bool _isLoading = true;
  String? _error;

  QueryDocumentSnapshot? _solicitudSeleccionada;

  bool _ocultarCompletadas = true;

  StreamSubscription<QuerySnapshot>? _solicitudesSubscription;

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
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _iniciarConexionLimpia();
      } else {
        _apagarConexion();
      }
    });
  }

  void _iniciarConexionLimpia() {
    _error = null;
    _isLoading = true;
    notifyListeners();

    _solicitudesSubscription?.cancel();

    _solicitudesSubscription = FirebaseFirestore.instance.collection('solicitudes').snapshots().listen(
      (snapshot) {
        _solicitudes = snapshot.docs;
        _error = null; 
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

  void _apagarConexion() {
    _solicitudesSubscription?.cancel();
    _solicitudes = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _solicitudesSubscription?.cancel(); 
    super.dispose();
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