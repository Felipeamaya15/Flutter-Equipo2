import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; 
import 'dart:math';
import '../../../../core/routes/app_routes.dart';
import '../../../dashboard/presentacion/providers/solicitudes_provider.dart';
import '../widgets/reusable_solicitud_form.dart';

class SolicitudFormPage extends StatefulWidget {
  const SolicitudFormPage({super.key});

  @override
  State<SolicitudFormPage> createState() => _SolicitudFormPageState();
}

class _SolicitudFormPageState extends State<SolicitudFormPage> {
  bool _isSubmitting = false;

  Future<void> _handleFormSubmit(String email, String phone, DateTime date) async {
    setState(() => _isSubmitting = true);

    try {
      final String folioGenerado = (10000 + Random().nextInt(90000)).toString();

      await FirebaseFirestore.instance.collection('solicitudes').add({
        'folio': folioGenerado,
        'emailCliente': email,
        'telefonoCliente': phone,
        'fechaEvento': Timestamp.fromDate(date),
        'estado': 'Pendiente',
        'usuarioAsignado': 'Sin asignar',
        'nombreEvento': 'Logística de Evento Gastronómico',
      });

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.confirmation,
        arguments: {
          'folio': folioGenerado,
          'email': email,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la solicitud en la base de datos: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escucha el Provider del Dashboard para verificar si el usuario seleccionó un registro
    final solicitudesProvider = Provider.of<SolicitudesProvider>(context);
    final solicitudSeleccionada = solicitudesProvider.solicitudSeleccionada;
    final bool esModoDetalle = solicitudSeleccionada != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: Text(
          esModoDetalle ? 'Detalle de Solicitud' : 'Solicitud de Cotización',
          style: const TextStyle(color: Color(0xFF4A4B22), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: esModoDetalle
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF4A4B22)),
                onPressed: () {
                  solicitudesProvider.clearSeleccion();
                  Navigator.of(context).pop();
                },
              )
            : null,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ReusableSolicitudForm(
            onSubmit: _handleFormSubmit,
            isLoading: _isSubmitting,
            readOnly: esModoDetalle,
            initialEmail: esModoDetalle ? solicitudSeleccionada.get('emailCliente') as String? : null,
initialPhone: esModoDetalle ? solicitudSeleccionada.get('telefonoCliente') as String? : null,
initialDate: esModoDetalle ? (solicitudSeleccionada.get('fechaEvento') as Timestamp?)?.toDate() : null,
          ),
        ),
      ),
    );
  }
}