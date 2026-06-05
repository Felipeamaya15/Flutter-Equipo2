import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; 
import 'dart:math';
import '../../../../core/routes/app_routes.dart';
import '../../../dashboard/presentacion/providers/solicitudes_provider.dart';
import '../widgets/reusable_solicitud_form.dart';
import '../widgets/cotizacion_document_view.dart';

class SolicitudFormPage extends StatefulWidget {
  const SolicitudFormPage({super.key});

  @override
  State<SolicitudFormPage> createState() => _SolicitudFormPageState();
}

class _SolicitudFormPageState extends State<SolicitudFormPage> {
  bool _isSubmitting = false;

  Future<void> _handleFormSubmit(Map<String, dynamic> datosCotizacion) async {
    setState(() => _isSubmitting = true);

    try {
      final String folioGenerado = (10000 + Random().nextInt(90000)).toString();

      await FirebaseFirestore.instance.collection('solicitudes').add({
        'folio': folioGenerado,
        'estado': 'Pendiente',
        'usuarioAsignado': datosCotizacion['usuarioAsignado'] ?? 'Sin asignar',
        'creado_en': FieldValue.serverTimestamp(),

        // I. DATOS DEL CLIENTE
        'tipoCliente': datosCotizacion['tipoCliente'],
        'emailCliente': datosCotizacion['emailCliente'],
        'telefonoCliente': datosCotizacion['telefonoCliente'],
        'nombreCliente': datosCotizacion['nombreCliente'],
        'rutCliente': datosCotizacion['rutCliente'],
        'giroEmpresa': datosCotizacion['giroEmpresa'],
        'direccionComercial': datosCotizacion['direccionComercial'], 
        'nombreContactoEmpresa': datosCotizacion['nombreContactoEmpresa'], 

        // II. LOGÍSTICA DEL EVENTO
        'nombreEvento': datosCotizacion['tipoEvento'] ?? 'Logística de Evento Gastronómico',
        'fechaEvento': Timestamp.fromDate(datosCotizacion['fechaEvento']),
        'horaInicio': datosCotizacion['horaInicio'],
        'horaTermino': datosCotizacion['horaTermino'],
        'cantidadAsistentes': datosCotizacion['cantidadAsistentes'],
        'lugarEvento': datosCotizacion['lugarEvento'],
        'tipoEspacio': datosCotizacion['tipoEspacio'],

        // III. PROPUESTA GASTRONÓMICA
        'formatoServicio': datosCotizacion['formatoServicio'],
        'preferenciasMenu': datosCotizacion['preferenciasMenu'], 
        'restriccionesAlimentarias': datosCotizacion['restriccionesAlimentarias'],
        'detallesEspeciales': datosCotizacion['detallesEspeciales'],
      });

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.confirmation,
        arguments: {
          'folio': folioGenerado,
          'email': datosCotizacion['emailCliente'],
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar la cotización en Firebase: $e'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final solicitudesProvider = Provider.of<SolicitudesProvider>(context);
    final solicitudSeleccionada = solicitudesProvider.solicitudSeleccionada;
    final bool esModoDetalle = solicitudSeleccionada != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: Text(
          esModoDetalle ? 'Resumen de Cotización' : 'Solicitud de Cotización',
          style: const TextStyle(
            color: Color(0xFF4A4B22), 
            fontWeight: FontWeight.bold, 
            fontSize: 18
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A4B22)),
          onPressed: () {
            if (esModoDetalle) {
              solicitudesProvider.clearSeleccion();
            }
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            constraints: const BoxConstraints(maxWidth: 650),
            child: esModoDetalle
                ? CotizacionDocumentView(solicitudDoc: solicitudSeleccionada)
                : ReusableSolicitudForm(
                    onSubmit: _handleFormSubmit,
                    isLoading: _isSubmitting,
                    readOnly: false,
                    solicitudDoc: null,
                  ),
          ),
        ),
      ),
    );
  }
}