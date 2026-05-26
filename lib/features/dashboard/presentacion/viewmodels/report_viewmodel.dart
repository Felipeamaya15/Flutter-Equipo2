import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _subscription;

  bool isLoading = true;
  String? errorMessage;
  
  int totalSolicitudes = 0;
  int pendientes = 0;
  int enProceso = 0;
  int completadas = 0;
  int solicitudesAsignadas = 0;
  int solicitudesSinAsignar = 0;

  Map<String, int> eventosPorMes = {};

  final List<String> _nombreMeses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  void initSnapshotListener() {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    _subscription = _firestore.collection('solicitudes').snapshots().listen(
      (snapshot) {
        final docs = snapshot.docs;
        totalSolicitudes = docs.length;

        // GRAFICO DE TORTA ESTADO DE SOLICITUDES
        pendientes = docs.where((doc) {
          final estado = (doc.data()['estado'] ?? '').toString().trim().toLowerCase();
          return estado == 'pendiente';
        }).length;

        enProceso = docs.where((doc) {
          final estado = (doc.data()['estado'] ?? '').toString().trim().toLowerCase();
          return estado == 'en proceso' || estado == 'en_proceso';
        }).length;

        completadas = docs.where((doc) {
          final estado = (doc.data()['estado'] ?? '').toString().trim().toLowerCase();
          return estado == 'completado';
        }).length;

        // GRAFICO DE BARRAS ASIGNACIÓN DE COTIZACIONES
        solicitudesSinAsignar = docs.where((doc) {
          final asignado = (doc.data()['usuarioAsignado'] ?? '').toString().trim().toLowerCase();
          return asignado.isEmpty || asignado == 'sin asignar' || asignado == 'null';
        }).length;

        solicitudesAsignadas = totalSolicitudes - solicitudesSinAsignar;

        // GRAFICO DE BARRAS CRONOLÓGICO DE LOS EVENTOS POR MES
        eventosPorMes.clear();
        
        final docsConFecha = docs.where((doc) => doc.data()['fecha_evento'] != null);

        for (var doc in docsConFecha) {
          try {
            final Timestamp timestamp = doc.data()['fecha_evento'] as Timestamp;
            final DateTime fecha = timestamp.toDate();
            final String mesClave = _nombreMeses[fecha.month - 1];
            
            eventosPorMes[mesClave] = (eventosPorMes[mesClave] ?? 0) + 1;
          } catch (e) {
            continue;
          }
        }

        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        isLoading = false;
        errorMessage = 'Error al conectar con el servidor: $error';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}