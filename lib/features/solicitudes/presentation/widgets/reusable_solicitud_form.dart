import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';

class ReusableSolicitudForm extends StatefulWidget {
  final Future<void> Function(String email, String phone, DateTime date)
      onSubmit;
  final bool isLoading;

  const ReusableSolicitudForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<ReusableSolicitudForm> createState() => _ReusableSolicitudFormState();
}

class _ReusableSolicitudFormState extends State<ReusableSolicitudForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  DateTime? _selectedDate;
  String? _dateError;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
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
    final dateValidation = Validators.futureDate(_selectedDate);

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
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              hintText: 'ejemplo@correo.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            enabled: !widget.isLoading,
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
            validator: Validators.phone,
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: widget.isLoading ? null : _selectDate,
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submitForm,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Enviar solicitud'),
            ),
          ),
        ],
      ),
    );
  }
}