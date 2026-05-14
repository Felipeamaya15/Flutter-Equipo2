import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //
import '../widgets/reusable_solicitud_form.dart';

class SolicitudForm extends StatefulWidget {
  @override
  _SolicitudFormState createState() => _SolicitudFormState();
}

class _SolicitudFormState extends State<SolicitudForm> {
  bool _isSubmitting = false;

  // Lógica de guardado en Firebase
  Future<void> _saveToFirebase(String email, String phone, DateTime date) async {
    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('solicitudes').add({
        'email': email,
        'phone': phone,
        'fecha_evento': date,
        'creado_en': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Solicitud enviada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Solicitud de Cotización")),
      body: ReusableSolicitudForm(
        isLoading: _isSubmitting,
        onSubmit: _saveToFirebase, // Pasamos la función como callback
      ),
    );
  }
}