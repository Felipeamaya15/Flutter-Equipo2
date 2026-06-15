import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_equipo2/core/utils/validators.dart';

class ReusableSolicitudForm extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> data) onSubmit;
  final bool isLoading;
  final bool readOnly;
  final QueryDocumentSnapshot? solicitudDoc;

  const ReusableSolicitudForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.readOnly = false,
    this.solicitudDoc,
  });

  @override
  State<ReusableSolicitudForm> createState() => _ReusableSolicitudFormState();
}
 
class _ReusableSolicitudFormState extends State<ReusableSolicitudForm> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  String _tipoCliente = 'Persona'; 
  late final TextEditingController _nombreClienteController; 
  late final TextEditingController _rutController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _giroController;
  late final TextEditingController _direccionComercialController;
  late final TextEditingController _nombreContactoEmpresaController;

  String _tipoEvento = 'Evento Corporativo / Empresa';
  DateTime? _selectedDate;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaTermino;
  late final TextEditingController _asistentesController;
  late final TextEditingController _lugarController;
  String _tipoEspacio = 'Salón Cerrado';

  String _formatoServicio = 'Banquetería Completa (Cóctel + Entrada + Fondo + Postre)';
  final List<String> _preferenciasMenu = [];
  final List<String> _restriccionesAlimentarias = [];
  late final TextEditingController _detallesEspecialesController;

  String _encargadoSeleccionado = 'Sin asignar';
  // ignore: prefer_final_fields
  List<String> _listaEncargados = ['Sin asignar', 'Coordinador General', 'María González', 'Juan Pérez', 'Ana Martínez'];

  @override
  void initState() {
    super.initState();
    final data = widget.solicitudDoc?.data() as Map<String, dynamic>?;
    if (data != null) {
      _tipoCliente = data['tipoCliente'] ?? 'Persona';
      _nombreClienteController = TextEditingController(text: data['nombreCliente'] ?? (data['emailCliente'] != null ? 'Cliente Registrado' : ''));
      _rutController = TextEditingController(text: data['rutCliente'] ?? '');
      _emailController = TextEditingController(text: data['emailCliente'] ?? '');
      _phoneController = TextEditingController(text: data['telefonoCliente'] ?? '');
      _giroController = TextEditingController(text: data['giroEmpresa'] ?? '');
      _direccionComercialController = TextEditingController(text: data['direccionComercial'] ?? '');
      _nombreContactoEmpresaController = TextEditingController(text: data['nombreContactoEmpresa'] ?? '');

      _tipoEvento = data['nombreEvento'] ?? 'Seleccionar tipo de evento';
      _selectedDate = (data['fechaEvento'] as Timestamp?)?.toDate();
      
      if (data['horaInicio'] != null) {
        final partes = data['horaInicio'].toString().split(':');
        _horaInicio = TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
      }
      if (data['horaTermino'] != null) {
        final partes = data['horaTermino'].toString().split(':');
        _horaTermino = TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
      }

      _asistentesController = TextEditingController(text: data['cantidadAsistentes']?.toString() ?? '');
      _lugarController = TextEditingController(text: data['lugarEvento'] ?? '');
      _tipoEspacio = data['tipoEspacio'] ?? 'Seleccionar tipo de espacio';

      _formatoServicio = data['formatoServicio'] ?? 'Banquetería Completa (Cóctel + Entrada + Fondo + Postre)';
      if (data['preferenciasMenu'] != null) {
        _preferenciasMenu.addAll(List<String>.from(data['preferenciasMenu']));
      }
      if (data['restriccionesAlimentarias'] != null) {
        _restriccionesAlimentarias.addAll(List<String>.from(data['restriccionesAlimentarias']));
      }
      _detallesEspecialesController = TextEditingController(text: data['detallesEspeciales'] ?? '');
      _encargadoSeleccionado = data['usuarioAsignado'] ?? 'Sin asignar';
    } 
    else {
      _tipoCliente = 'Persona';
      _nombreClienteController = TextEditingController();
      _rutController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _giroController = TextEditingController();
      _direccionComercialController = TextEditingController();
      _nombreContactoEmpresaController = TextEditingController();

      _tipoEvento = 'Seleccionar tipo de evento';
      _selectedDate = null;
      _horaInicio = null;
      _horaTermino = null;
      _asistentesController = TextEditingController();
      _lugarController = TextEditingController();
      _tipoEspacio = 'Seleccionar tipo de espacio';

      _formatoServicio = 'Seleccionar formato de servicio';
      _detallesEspecialesController = TextEditingController();
      _encargadoSeleccionado = 'Sin asignar';
    }
    if (!_listaEncargados.contains(_encargadoSeleccionado)) {
      _listaEncargados.add(_encargadoSeleccionado);
    }
  }

  @override
  void dispose() {
    _nombreClienteController.dispose();
    _rutController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _giroController.dispose();
    _direccionComercialController.dispose();
    _nombreContactoEmpresaController.dispose();
    _asistentesController.dispose();
    _lugarController.dispose();
    _detallesEspecialesController.dispose();
    super.dispose();
  }
  String _formatTimeAMPM(TimeOfDay time) {
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _selectDate() async {
    if (widget.readOnly) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(bool isInicio) async {
    if (widget.readOnly) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: isInicio ? (_horaInicio ?? const TimeOfDay(hour: 9, minute: 0)) : (_horaTermino ?? const TimeOfDay(hour: 18, minute: 0)),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _horaInicio = picked;
        } else {
          _horaTermino = picked;
        }
      });
    }
  }

  void _agregarEncargadoModal() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nuevo Encargado', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4B22))),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A4B22)),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _listaEncargados.add(controller.text.trim());
                  _encargadoSeleccionado = controller.text.trim();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona la fecha del evento.'), backgroundColor: Colors.orange));
      return;
    }

    final datosFinales = {
      'tipoCliente': _tipoCliente,
      'nombreCliente': _nombreClienteController.text.trim(),
      'rutCliente': _rutController.text.trim(),
      'emailCliente': _emailController.text.trim(),
      'telefonoCliente': _phoneController.text.trim(),
      'giroEmpresa': _tipoCliente == 'Empresa' ? _giroController.text.trim() : '',
      'direccionComercial': _tipoCliente == 'Empresa' ? _direccionComercialController.text.trim() : '',
      'nombreContactoEmpresa': _tipoCliente == 'Empresa' ? _nombreContactoEmpresaController.text.trim() : '',
      'tipoEvento': _tipoEvento,
      'fechaEvento': _selectedDate,
      // Firebase lo guarda en 24h internamente (perfecto para la base de datos)
      'horaInicio': _horaInicio != null ? '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}' : '09:00',
      'horaTermino': _horaTermino != null ? '${_horaTermino!.hour.toString().padLeft(2, '0')}:${_horaTermino!.minute.toString().padLeft(2, '0')}' : '18:00',
      'cantidadAsistentes': int.tryParse(_asistentesController.text) ?? 10,
      'lugarEvento': _lugarController.text.trim(),
      'tipoEspacio': _tipoEspacio,
      'formatoServicio': _formatoServicio,
      'preferenciasMenu': _preferenciasMenu,
      'restriccionesAlimentarias': _restriccionesAlimentarias,
      'detallesEspeciales': _detallesEspecialesController.text.trim(),
      'usuarioAsignado': _encargadoSeleccionado,
    };

    widget.onSubmit(datosFinales);
  }

  @override
  Widget build(BuildContext context) {
    const Color verdeEmpresa = Color(0xFF4A4B22);
    bool cruzaMedianoche = false;
    if (_horaInicio != null && _horaTermino != null) {
      final inicioMin = _horaInicio!.hour * 60 + _horaInicio!.minute;
      final terminoMin = _horaTermino!.hour * 60 + _horaTermino!.minute;
      if (terminoMin < inicioMin) cruzaMedianoche = true;
    }

    return Form(
      key: _formKey,
      child:Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: verdeEmpresa,
            secondary: verdeEmpresa,
          ),
        ),
      child: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        physics: const NeverScrollableScrollPhysics(),
        
        onStepCancel: _currentStep == 0 ? null : () => setState(() => _currentStep--),
        onStepContinue: () {
          if (widget.isLoading) return;

          bool isCurrentStepValid = false;

          if (_currentStep == 0) {
            String nombre = _nombreClienteController.text.trim();
            bool nameValid = nombre.isNotEmpty;
            if (_tipoCliente == 'Persona' && nameValid) {
              nameValid = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(nombre);
            }
            
            bool rutValid = Validators.rut(_rutController.text) == null;
            bool emailValid = Validators.email(_emailController.text) == null;
            bool phoneValid = Validators.phone(_phoneController.text) == null;

            if (_tipoCliente == 'Empresa') {
              bool giroValid = Validators.requiredField(_giroController.text, 'Giro Comercial') == null;
              bool dirValid = Validators.requiredField(_direccionComercialController.text, 'Dirección Comercial') == null;
              bool contactValid = Validators.requiredField(_nombreContactoEmpresaController.text, 'Nombre del Coordinador') == null;
              isCurrentStepValid = nameValid && rutValid && emailValid && phoneValid && giroValid && dirValid && contactValid;
            } else {
              isCurrentStepValid = nameValid && rutValid && emailValid && phoneValid;
            }

            if (!isCurrentStepValid) _formKey.currentState!.validate();

          } else if (_currentStep == 1) {
            bool eventTypeValid = _tipoEvento != 'Seleccionar tipo de evento';
            bool dateValid = Validators.futureDate(_selectedDate) == null;
            bool guestsValid = _asistentesController.text.isNotEmpty && int.tryParse(_asistentesController.text) != null && int.parse(_asistentesController.text) > 0;
            bool placeValid = _lugarController.text.isNotEmpty;
            bool spaceValid = _tipoEspacio != 'Seleccionar tipo de espacio';
            
            bool timeValid = true;
            if (_horaInicio == null || _horaTermino == null) {
              timeValid = false;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes seleccionar hora de inicio y de término.'), backgroundColor: Colors.red));
            } else {
              final inicioMin = _horaInicio!.hour * 60 + _horaInicio!.minute;
              final terminoMin = _horaTermino!.hour * 60 + _horaTermino!.minute;
              // Si la duración es literalmente 0 minutos (Empieza a las 15:00 y termina a las 15:00), ahí sí bloqueamos.
              if (inicioMin == terminoMin) { 
                timeValid = false;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: La hora de inicio y término no pueden ser exactamente iguales.'), backgroundColor: Colors.red));
              }
            }

            isCurrentStepValid = eventTypeValid && dateValid && guestsValid && placeValid && spaceValid && timeValid;
            
            if (!isCurrentStepValid) _formKey.currentState!.validate();

          } else if (_currentStep == 2) {
            isCurrentStepValid = _formatoServicio != 'Seleccionar formato de servicio';
            if (!isCurrentStepValid) _formKey.currentState!.validate();

          } else if (_currentStep == 3) {
            isCurrentStepValid = _formKey.currentState!.validate();
          }

          if (isCurrentStepValid) {
            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else if (!widget.readOnly) {
              _submitForm();
            }
          } else {
            if (_currentStep != 1 || (_horaInicio != null && _horaTermino != null && (_horaInicio!.hour * 60 + _horaInicio!.minute) != (_horaTermino!.hour * 60 + _horaTermino!.minute))) {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, corrige los errores en el formulario para avanzar.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
        controlsBuilder: (context, controls) {
          return Padding(
            padding: const EdgeInsets.only(top:20.0),
            child: Row(
              children: [
                if(!widget.readOnly || _currentStep < 3)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A4B22),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: widget.isLoading ? null : controls.onStepContinue,
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_currentStep == 3 ? 'Finalizar' : 'Siguiente'), 
                    ),
                  ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                      onPressed: widget.isLoading ? null : controls.onStepCancel,
                      child: const Text('Atrás'),
                    ),
                  ),
                ]
              ],
            ),
          );
        },
        steps: [
          // DATOS DEL CLIENTE
          Step(
            title: const Text('Datos del Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.editing,
            content: Column(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Persona', label: Text('Persona Natural'), icon: Icon(Icons.person)),
                    ButtonSegment(value: 'Empresa', label: Text('Empresa / Corp'), icon: Icon(Icons.business)),
                  ],
                  selected: {_tipoCliente},
                  onSelectionChanged: widget.readOnly ? null : (val) {
                    setState(() {
                      _tipoCliente = val.first;
                      _nombreClienteController.clear();
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreClienteController,
                  decoration: InputDecoration(labelText: _tipoCliente == 'Persona' ? 'Nombre Completo' : 'Razón Social de la Empresa', border: const OutlineInputBorder()),
                  enabled: !widget.readOnly,
                  inputFormatters: [
                    if (_tipoCliente == 'Persona')
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Este campo es obligatorio';
                    if (_tipoCliente == 'Persona') {
                      if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(v)) {
                        return 'El nombre solo puede contener letras y espacios';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _rutController,
                  decoration: const InputDecoration(labelText: 'RUT (Ej: 12.345.678-9)', border: OutlineInputBorder()),
                  enabled: !widget.readOnly,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9kK\.\-]')),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'El RUT es obligatorio';
                    String? error = Validators.rut(v);
                    if (error != null) return 'Formato inválido. Usa puntos y guion';
                    return null; 
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico', 
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => Validators.email(v),
                        enabled: !widget.readOnly,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono', 
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        ),
                          inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                        ],
                        validator: (v) => Validators.phone(v),
                        enabled: !widget.readOnly,
                      ),
                    ),
                  ],
                ),
                if (_tipoCliente == 'Empresa') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _giroController, 
                    decoration: const InputDecoration(labelText: 'Giro Comercial (SII)', border: OutlineInputBorder()), 
                    enabled: !widget.readOnly,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s]')),
                    ],
                    validator: (v) => _tipoCliente == 'Empresa' ? Validators.requiredField(v, 'Giro Comercial') : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _direccionComercialController,
                    decoration: const InputDecoration(labelText: 'Dirección Comercial de Facturación', border: OutlineInputBorder()),
                    enabled: !widget.readOnly,
                    validator: (v) => _tipoCliente == 'Empresa' ? Validators.requiredField(v, 'Dirección Comercial') : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombreContactoEmpresaController,
                    decoration: const InputDecoration(labelText: 'Nombre del Coordinador/Contacto', border: OutlineInputBorder()), 
                    enabled: !widget.readOnly,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                    ],
                    validator: (v) => _tipoCliente == 'Empresa' ? Validators.requiredField(v, 'Nombre del Coordinador') : null,
                  ),
                ]
              ],
            ),
          ),
          // LOGÍSTICA DEL EVENTO
          Step(
            title: const Text('Logística del Evento', style: TextStyle(fontWeight: FontWeight.bold)),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.editing,
            content: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                    child: Text(
                      'Tipo de Evento',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A4B22)),
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _tipoEvento,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14), 
                  ),
                  validator: (v) {
                    if (v == null || v == 'Seleccionar tipo de evento') {
                      return 'Por favor, debes seleccionar un tipo de evento';
                    }
                    return null;
                  },
                  items: [
                    'Seleccionar tipo de evento',
                    'Matrimonio', 
                    'Evento Corporativo / Empresa', 
                    'Cumpleaños / Aniversario', 
                    'Graduación', 
                    'Coctel / Lanzamiento', 
                    'Almuerzo/Cena Privada'
                  ].map((e) {
                    return DropdownMenuItem(
                      value: e, 
                      child: Text(
                        e, 
                        style: TextStyle(color: e == 'Seleccionar tipo de evento' ? Colors.grey.shade500 : Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: widget.readOnly ? null : (v) => setState(() => _tipoEvento = v!),
                ),
                const SizedBox(height: 12),
                FormField<DateTime>(
                  initialValue: _selectedDate,
                  validator: (value) => Validators.futureDate(_selectedDate),
                  builder: (FormFieldState<DateTime> state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            _selectedDate == null 
                                ? 'Seleccionar Fecha' 
                                : 'Fecha: ${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                          ),
                          trailing: Icon(
                            Icons.calendar_today, 
                            color: state.hasError ? Colors.red.shade700 : const Color(0xFF4A4B22),
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: state.hasError ? Colors.red.shade700 : Colors.grey.shade400,
                              width: state.hasError ? 2.0 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onTap: () async {
                            await _selectDate();
                            state.didChange(_selectedDate);
                          },
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0, top: 6.0),
                            child: Text(state.errorText!, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(_horaInicio == null ? 'Hora Inicio' : 'Inicia: ${_formatTimeAMPM(_horaInicio!)}', style: const TextStyle(fontSize: 14)),
                        trailing: const Icon(Icons.access_time),
                        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                        onTap: () => _selectTime(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_horaTermino == null ? 'Hora Término' : 'Termina: ${_formatTimeAMPM(_horaTermino!)}', style: const TextStyle(fontSize: 14)),
                            if (cruzaMedianoche)
                              Text('(+1 día)', style: TextStyle(color: Colors.orange.shade800, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: const Icon(Icons.access_time),
                        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                        onTap: () => _selectTime(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _asistentesController,
                  decoration: const InputDecoration(labelText: 'Cantidad de Asistentes', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa el número de invitados';
                    if (int.tryParse(v) == null || int.parse(v) <= 0) return 'Debe ser mayor a 0';
                    return null;
                  },
                  enabled: !widget.readOnly,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lugarController, 
                  decoration: const InputDecoration(labelText: 'Lugar / Dirección del Evento', border: OutlineInputBorder()), 
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Lugar obligatorio';
                    if (v.trim().length < 5) return 'Debe tener al menos 5 caracteres';
                    return null;
                  },
                  enabled: !widget.readOnly,
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                    child: Text(
                      'Tipo de Espacio',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A4B22)),
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _tipoEspacio,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v == 'Seleccionar tipo de espacio') {
                      return 'Por favor, debes seleccionar un tipo de espacio';
                    }
                    return null;
                  },
                  items: [
                    'Seleccionar tipo de espacio',
                    'Aire Libre', 
                    'Salón Cerrado', 
                    'Espacio Mixto (Terraza/Salón)'
                  ].map((e) {
                    return DropdownMenuItem(
                      value: e, 
                      child: Text(
                        e, 
                        style: TextStyle(color: e == 'Seleccionar tipo de espacio' ? Colors.grey.shade500 : Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: widget.readOnly ? null : (v) => setState(() => _tipoEspacio = v!),
                ),
              ],
            ),
          ),
          // PROPUESTA GASTRONÓMICA 
          Step(
            title: const Text('Menú y Experiencia', style: TextStyle(fontWeight: FontWeight.bold)),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.editing,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                    child: Text(
                      'Formato del Servicio',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A4B22)),
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _formatoServicio,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v == 'Seleccionar formato de servicio') {
                      return 'Por favor, debes seleccionar un formato de servicio';
                    }
                    return null;
                  },
                  items: [
                    'Seleccionar formato de servicio',
                    'Banquetería Completa (Cóctel + Entrada + Fondo + Postre)',
                    'Solo Cóctel / Finger Food', 
                    'Buffet Intercultural', 
                    'Coffee Break / Té de Honor'
                  ].map((e) {
                    return DropdownMenuItem(
                      value: e, 
                      child: Text(
                        e, 
                        style: TextStyle(color: e == 'Seleccionar formato de servicio' ? Colors.grey.shade500 : Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: widget.readOnly ? null : (v) => setState(() => _formatoServicio = v!),
                ),
                const SizedBox(height: 16),
                const Text('Preferencia de Menú Temático', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4B22))),
                ...['Fusión Intercultural', 'Gastronomía Típica Chilena', 'Cocina Internacional', 'Menú de Autor'].map((item) {
                  return CheckboxListTile(
                    title: Text(item),
                    value: _preferenciasMenu.contains(item),
                    onChanged: widget.readOnly ? null : (bool? checked) {
                      setState(() {
                        if (checked!) {
                          _preferenciasMenu.add(item);
                        } else {
                          _preferenciasMenu.remove(item);
                        }
                      });
                    },
                  );
                }),
                const SizedBox(height: 12),
                const Text('Restricciones Alimentarias', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4B22))),
                ...['Vegano', 'Vegetariano', 'Sin Gluten (Celiacos)', 'Sin Lactosa'].map((item) {
                  return CheckboxListTile(
                    title: Text(item),
                    value: _restriccionesAlimentarias.contains(item),
                    onChanged: widget.readOnly ? null : (bool? checked) {
                      setState(() {
                        if (checked!) {
                          _restriccionesAlimentarias.add(item);
                        } else {
                          _restriccionesAlimentarias.remove(item);
                        }
                      });
                    },
                  );
                }),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _detallesEspecialesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descripción y Detalles Especiales', hintText: 'Escribe aquí montajes, decoraciones particulares...', border: OutlineInputBorder()),
                  enabled: !widget.readOnly,
                ),
              ],
            ),
          ),

          //ASIGNACIÓN DE ENCARGADO
          Step(
            title: const Text('Asignación de Encargado', style: TextStyle(fontWeight: FontWeight.bold)),
            isActive: _currentStep >= 3,
            state: StepState.editing,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                    child: Text(
                      'Encargado de la Cotización',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A4B22)),
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _encargadoSeleccionado,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),

                  validator: (v) {
                    if (v == null || v == 'Sin asignar'){
                      return 'Por favor, asigna un encargado a esta cotización';
                    }
                    return null;
                  },

                  items: _listaEncargados.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: widget.readOnly ? null : (v) => setState(() => _encargadoSeleccionado = v!),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lista de Encargados Disponibles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    if (!widget.readOnly)
                      IconButton(icon: const Icon(Icons.add_circle, color: Color(0xFF4A4B22), size: 28), onPressed: _agregarEncargadoModal)
                  ],
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  
                  itemCount: _listaEncargados.length,
                  itemBuilder: (context, index) {
                    final nombre = _listaEncargados[index];
                    if (nombre == 'Sin asignar') return const SizedBox.shrink();

                    return Dismissible(
                      key: Key(nombre),
                      direction: widget.readOnly ? DismissDirection.none : DismissDirection.endToStart,
                      background: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('¿Eliminar Encargado?'),
                            content: Text('¿Estás seguro de que quieres quitar a $nombre de la lista operativa?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        setState(() {
                          _listaEncargados.removeAt(index);
                          if (_encargadoSeleccionado == nombre) {
                            _encargadoSeleccionado = 'Sin asignar';
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Encargado $nombre removido.')));
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.account_circle, color: Colors.grey),
                          title: Text(nombre),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}