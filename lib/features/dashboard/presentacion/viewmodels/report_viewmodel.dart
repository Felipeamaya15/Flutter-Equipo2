import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportViewModel extends ChangeNotifier {
  final FirebaseFirestore? _firestore;

  ReportViewModel({FirebaseFirestore? firestore}) : _firestore = firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  StreamSubscription? _subscription;

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
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  void initSnapshotListener() {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    _subscription = firestore.collection('solicitudes').snapshots().listen(
      (snapshot) {
        final docs = snapshot.docs;

        totalSolicitudes = docs.length;

        // Gráfico de torta: estado de solicitudes
        pendientes = docs.where((doc) {
          final estado =
              (doc.data()['estado'] ?? '').toString().trim().toLowerCase();
          return estado == 'pendiente';
        }).length;

        enProceso = docs.where((doc) {
          final estado =
              (doc.data()['estado'] ?? '').toString().trim().toLowerCase();
          return estado == 'en proceso' || estado == 'en_proceso';
        }).length;

        completadas = docs.where((doc) {
          final estado =
              (doc.data()['estado'] ?? '').toString().trim().toLowerCase();
          return estado == 'completado';
        }).length;

        // Gráfico de barras: asignación de cotizaciones
        solicitudesSinAsignar = docs.where((doc) {
          final asignado = (doc.data()['usuarioAsignado'] ?? '')
              .toString()
              .trim()
              .toLowerCase();

          return asignado.isEmpty ||
              asignado == 'sin asignar' ||
              asignado == 'null';
        }).length;

        solicitudesAsignadas = totalSolicitudes - solicitudesSinAsignar;

        // Gráfico cronológico: eventos por mes
        eventosPorMes.clear();

        final docsConFecha =
            docs.where((doc) => doc.data()['fecha_evento'] != null);

        for (final doc in docsConFecha) {
          try {
            final Timestamp timestamp = doc.data()['fecha_evento'] as Timestamp;
            final DateTime fecha = timestamp.toDate();
            final String mesClave = _nombreMeses[fecha.month - 1];

            eventosPorMes[mesClave] = (eventosPorMes[mesClave] ?? 0) + 1;
          } catch (_) {
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

  bool validarRangoFechas(DateTime? fechaDesde, DateTime? fechaHasta) {
    if (fechaDesde == null || fechaHasta == null) {
      errorMessage = 'Debes seleccionar ambas fechas para generar el reporte.';
      notifyListeners();
      return false;
    }

    if (fechaDesde.isAfter(fechaHasta)) {
      errorMessage =
          'La fecha "Desde" no puede ser posterior a la fecha "Hasta".';
      notifyListeners();
      return false;
    }

    errorMessage = null;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}