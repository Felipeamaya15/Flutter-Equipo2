import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/solicitud_remote_datasource.dart';
import '../../data/repositories/solicitud_repository_impl.dart';
import '../../domain/entities/solicitud.dart';
import '../widgets/reusable_solicitud_form.dart';

class SolicitudFormPage extends StatefulWidget {
  const SolicitudFormPage({super.key});

  @override
  State<SolicitudFormPage> createState() => _SolicitudFormPageState();
}

class _SolicitudFormPageState extends State<SolicitudFormPage> {
  bool _isSubmitting = false;

  late final SolicitudRepositoryImpl _repository;

  @override
  void initState() {
    super.initState();

    _repository = SolicitudRepositoryImpl(
      datasource: SolicitudRemoteDatasource(
        firestore: FirebaseFirestore.instance,
      ),
    );
  }

  Future<void> _saveToFirebase(
    String email,
    String phone,
    DateTime date,
  ) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final id = const Uuid().v4();

      final solicitud = Solicitud(
        id: id,
        email: email,
        phone: phone,
        fechaEvento: date,
        estado: 'pendiente',
        fechaCreacion: DateTime.now(),
      );

      await _repository.crearSolicitud(solicitud);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud enviada con éxito. Folio: $id'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitud de Cotización'),
      ),
      body: ReusableSolicitudForm(
        isLoading: _isSubmitting,
        onSubmit: _saveToFirebase,
      ),
    );
  }
}