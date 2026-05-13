import 'package:flutter/material.dart';

class SolicitudForm extends StatefulWidget {
  @override
  _SolicitudFormState createState() => _SolicitudFormState();
}

class _SolicitudFormState extends State<SolicitudForm> {
  final _formKey = GlobalKey<FormState>();
  

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedDate;


  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Este campo es obligatorio';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Formato de correo no válido (usuario@dominio.com)';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Este campo es obligatorio';
    if (value.length != 9 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El teléfono debe tener exactamente 9 dígitos';
    }
    return null;
  }

 
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Solicitud de Cotización")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
              validator: _validateEmail,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Teléfono (9 dígitos)'),
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            ListTile(
              title: Text(_selectedDate == null 
                ? 'Seleccionar Fecha del Evento' 
                : 'Fecha: ${_selectedDate!.toLocal()}'.split(' ')[0]),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (_selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Por favor selecciona la fecha de tu evento '))
                    );
                    return;
                  }
                
                  print("Formulario validado correctamente");
                }
              },
              child: Text("Enviar Solicitud"),
            ),
          ],
        ),
      ),
    );
  }
}