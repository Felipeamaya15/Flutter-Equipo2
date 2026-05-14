import 'package:flutter/material.dart';

class ReusableSolicitudForm extends StatefulWidget {
  final Function(String email, String phone, DateTime date) onSubmit;
  final bool isLoading;

  const ReusableSolicitudForm({
    Key? key,
    required this.onSubmit,
    this.isLoading = false,
  }) : super(key: key);

  @override
  _ReusableSolicitudFormState createState() => _ReusableSolicitudFormState();
}

class _ReusableSolicitudFormState extends State<ReusableSolicitudForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedDate;

  // Validaciones Técnicas RF2
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Este campo es obligatorio';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Formato de correo no válido';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Este campo es obligatorio';
    // Validación estricta de 9 dígitos
    if (value.length != 9 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El teléfono debe tener exactamente 9 dígitos';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Correo Electrónico'),
            validator: _validateEmail,
            enabled: !widget.isLoading,
          ),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Teléfono (9 dígitos)'),
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
            enabled: !widget.isLoading,
          ),
          ListTile(
            title: Text(_selectedDate == null 
              ? 'Seleccionar Fecha del Evento' 
              : 'Fecha: ${_selectedDate!.toLocal()}'.split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: widget.isLoading ? null : () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now().add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.isLoading ? null : () {
              if (_formKey.currentState!.validate() && _selectedDate != null) {
                widget.onSubmit(
                  _emailController.text,
                  _phoneController.text,
                  _selectedDate!,
                );
              }
            },
            child: widget.isLoading 
              ? const CircularProgressIndicator() 
              : const Text("Enviar Solicitud"),
          ),
        ],
      ),
    );
  }
}