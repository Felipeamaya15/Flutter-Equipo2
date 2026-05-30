import 'package:flutter/material.dart';

class GenerarReporteDialog extends StatefulWidget {
  const GenerarReporteDialog({super.key});

  @override
  State<GenerarReporteDialog> createState() => _GenerarReporteDialogState();
}

class _GenerarReporteDialogState extends State<GenerarReporteDialog> {
  static const Color primaryColor = Color(0xFF4A4B22);
  String _tipoReporte = 'mensual';
  DateTime? _desde;
  DateTime? _hasta;

  Future<void> _selectDate(BuildContext context, bool isDesde) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDesde ? (_desde ?? now) : (_hasta ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        if (isDesde) {
          _desde = picked;
          if (_hasta != null && _hasta!.isBefore(picked)) {
            _hasta = null;
          }
        } else {
          _hasta = picked;
        }
      });
    }
  }

  void _exportarReporte() {
    if (_desde == null || _hasta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona rango de fechas antes de exportar.'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_hasta!.isBefore(_desde!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El rango de fechas no es válido.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Descargando reporte en formato PDF...'), backgroundColor: primaryColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.analytics_outlined, color: primaryColor),
          SizedBox(width: 8),
          Text('Generar Reporte', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: ReporteFormBody(
          tipoReporte: _tipoReporte,
          desde: _desde,
          hasta: _hasta,
          onTipoChanged: (value) => setState(() => _tipoReporte = value ?? _tipoReporte),
          onDesdeTap: () => _selectDate(context, true),
          onHastaTap: () => _selectDate(context, false),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton.icon(
          onPressed: _exportarReporte,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Exportar PDF'),
        ),
      ],
    );
  }
}

class ReporteFormBody extends StatelessWidget {
  const ReporteFormBody({
    super.key,
    required this.tipoReporte,
    required this.desde,
    required this.hasta,
    required this.onTipoChanged,
    required this.onDesdeTap,
    required this.onHastaTap,
  });

  final String tipoReporte;
  final DateTime? desde;
  final DateTime? hasta;
  final ValueChanged<String?> onTipoChanged;
  final VoidCallback onDesdeTap;
  final VoidCallback onHastaTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccione los parámetros para exportar el consolidado de datos operativos.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Tipo de Documento',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          initialValue: tipoReporte,
          items: const [
            DropdownMenuItem(value: 'mensual', child: Text('Resumen Mensual')),
            DropdownMenuItem(value: 'operadores', child: Text('Rendimiento por Operador')),
            DropdownMenuItem(value: 'financiero', child: Text('Proyección de Eventos')),
          ],
          onChanged: onTipoChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDesdeTap,
                icon: const Icon(Icons.date_range, size: 18),
                label: Text(desde == null ? 'Desde' : 'Desde: ${desde!.day}/${desde!.month}/${desde!.year}'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onHastaTap,
                icon: const Icon(Icons.date_range, size: 18),
                label: Text(hasta == null ? 'Hasta' : 'Hasta: ${hasta!.day}/${hasta!.month}/${hasta!.year}'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}