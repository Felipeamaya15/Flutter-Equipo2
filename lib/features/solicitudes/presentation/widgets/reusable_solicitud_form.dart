import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';

class ReusableSolicitudForm extends StatefulWidget {
  final Future<void> Function(String email, String phone, DateTime date) onSubmit;
  final bool isLoading;
  final bool readOnly;
  final String? initialEmail;
  final String? initialPhone;
  final DateTime? initialDate;

  const ReusableSolicitudForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.readOnly = false,
    this.initialEmail,
    this.initialPhone,
    this.initialDate,
  });

  @override
  State<ReusableSolicitudForm> createState() => _ReusableSolicitudFormState();
}

class _ReusableSolicitudFormState extends State<ReusableSolicitudForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  DateTime? _selectedDate;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    if (widget.readOnly) return;

    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _submitForm() async {
    if (widget.readOnly) return;

    String? dateValidation;
    if (_selectedDate == null) {
      dateValidation = 'Por favor selecciona la fecha de tu evento';
    } else {
      dateValidation = Validators.futureDate(_selectedDate);
    }

    setState(() {
      _dateError = dateValidation;
    });

    if (!_formKey.currentState!.validate() || dateValidation != null) {
      return;
    }

    await widget.onSubmit(
      _emailController.text.trim(),
      _phoneController.text.trim(),
      _selectedDate!,
    );

    if (!mounted) return;

    _emailController.clear();
    _phoneController.clear();
    setState(() {
      _selectedDate = null;
      _dateError = null;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView( 
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'ejemplo@correo.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El correo es obligatorio';
                }
                // RegExp para bloquear si no lleva el signo "@"
                if (!value.contains('@')) {
                  return 'El correo debe incluir un carácter "@"';
                }
                return Validators.email(value);
              },
              enabled: !widget.isLoading && !widget.readOnly,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                hintText: '912345678',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El teléfono es obligatorio';
                }
                // RegExp para bloquear si incluye cualquier letra
                final contieneLetras = RegExp(r'[a-zA-Z]');
                if (contieneLetras.hasMatch(value)) {
                  return 'El teléfono no puede incluir letras';
                }
                return Validators.phone(value);
              },
              enabled: !widget.isLoading && !widget.readOnly,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: (widget.isLoading || widget.readOnly) ? null : _selectDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Fecha del evento',
                  border: const OutlineInputBorder(),
                  errorText: _dateError, 
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Seleccionar fecha del evento'
                      : _formatDate(_selectedDate!),
                  style: TextStyle(
                    color: _selectedDate == null
                        ? Theme.of(context).hintColor
                        : Colors.black,
                  ),
                ),
              ),
            ),
            if (!widget.readOnly) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4B22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Enviar solicitud', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}