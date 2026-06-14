import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../viewmodels/report_viewmodel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GenerarReporteDialog extends StatefulWidget {
  const GenerarReporteDialog({super.key});

  @override
  State<GenerarReporteDialog> createState() => _GenerarReporteDialogState();
}

class _GenerarReporteDialogState extends State<GenerarReporteDialog> {
  static const Color primaryColor = Color(0xFF4A4B22);
  
  String _estadoReporte = 'Todas'; 
  DateTime? _desde;
  DateTime? _hasta;
  bool _isExporting = false;

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

  Future<void> _exportarReporte() async {
    final reportViewModel = context.read<ReportViewModel>();
    final rangoValido = reportViewModel.validarRangoFechas(_desde, _hasta);

    if (!rangoValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reportViewModel.errorMessage ?? 'El rango de fechas no es válido.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final snapshot = await FirebaseFirestore.instance.collection('solicitudes').get();
      List<QueryDocumentSnapshot> docs = snapshot.docs;

      docs = docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        final String estadoDoc = (data['estado'] ?? '').toString().trim().toLowerCase();
        if (_estadoReporte == 'Completadas' && estadoDoc != 'completado') return false;
        if (_estadoReporte == 'Pendientes' && estadoDoc == 'completado') return false;

        if (data['fechaEvento'] == null) return false; 
        
        try {
          final dynamic fechaRaw = data['fechaEvento'];
          if (fechaRaw is! Timestamp) return false;
          
          final DateTime fecha = fechaRaw.toDate();
          bool cumpleDesde = true;
          bool cumpleHasta = true;

          if (_desde != null) {
            final DateTime inicio = DateTime(_desde!.year, _desde!.month, _desde!.day);
            cumpleDesde = fecha.isAfter(inicio) || fecha.isAtSameMomentAs(inicio);
          }
          if (_hasta != null) {
            final DateTime fin = DateTime(_hasta!.year, _hasta!.month, _hasta!.day, 23, 59, 59);
            cumpleHasta = fecha.isBefore(fin) || fecha.isAtSameMomentAs(fin);
          }
          return cumpleDesde && cumpleHasta;
        } catch (e) {
          return false;
        }
      }).toList();

      final List<List<String>> tableData = docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final String folio = data['folio'] ?? 'S/N';
        final String cliente = data['nombreCliente'] ?? data['emailCliente'] ?? 'Sin nombre';
        final String evento = data['nombreEvento'] ?? 'Evento';
        final String estado = data['estado'] ?? 'Pendiente';
        
        String fechaStr = 'Sin fecha';
        if (data['fechaEvento'] != null) {
          final dynamic fRaw = data['fechaEvento'];
          if (fRaw is Timestamp) {
            final DateTime f = fRaw.toDate();
            fechaStr = '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
          }
        }

        return [folio, cliente, evento, fechaStr, estado];
      }).toList();

      final pdf = pw.Document();

      String tituloReporte = 'Reporte General de Solicitudes';
      if (_estadoReporte == 'Completadas') tituloReporte = 'Reporte de Eventos Completados';
      if (_estadoReporte == 'Pendientes') tituloReporte = 'Reporte de Eventos Pendientes';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Productora Intercultural SpA', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF4A4B22))),
                    pw.Text('Documento Oficial', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
                  ]
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(tituloReporte, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Fecha de Emisión: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const pw.TextStyle(fontSize: 14)),
              
              pw.SizedBox(height: 10),
              if (_desde != null) pw.Text('Período filtrado desde: ${_desde!.day}/${_desde!.month}/${_desde!.year}', style: const pw.TextStyle(fontSize: 14)),
              if (_hasta != null) pw.Text('Período filtrado hasta: ${_hasta!.day}/${_hasta!.month}/${_hasta!.year}', style: const pw.TextStyle(fontSize: 14)),
              
              pw.SizedBox(height: 20),

              if (tableData.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
                  child: pw.Text('No se encontraron registros para los filtros seleccionados.', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
                )
              else
                pw.TableHelper.fromTextArray(
                  headers: ['Folio', 'Cliente/Empresa', 'Tipo de Evento', 'Fecha', 'Estado'],
                  data: tableData,
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 11),
                  headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF4A4B22)),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellPadding: const pw.EdgeInsets.all(6),
                ),
                
              pw.SizedBox(height: 30),
              pw.Text('Total de registros encontrados: ${tableData.length}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Registro_Eventos_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (!mounted) return;
      Navigator.pop(context); 

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.picture_as_pdf_rounded, color: primaryColor),
          SizedBox(width: 8),
          Text('Descargar Registros', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: ReporteFormBody(
          estadoReporte: _estadoReporte,
          desde: _desde,
          hasta: _hasta,
          onEstadoChanged: (value) => setState(() => _estadoReporte = value ?? _estadoReporte),
          onDesdeTap: () => _selectDate(context, true),
          onHastaTap: () => _selectDate(context, false),
          isExporting: _isExporting,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _exportarReporte,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: _isExporting 
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.download_rounded, size: 18),
          label: Text(_isExporting ? 'Generando...' : 'Crear PDF'),
        ),
      ],
    );
  }
}

class ReporteFormBody extends StatelessWidget {
  const ReporteFormBody({
    super.key,
    required this.estadoReporte,
    required this.desde,
    required this.hasta,
    required this.onEstadoChanged,
    required this.onDesdeTap,
    required this.onHastaTap,
    required this.isExporting,
  });

  final String estadoReporte;
  final DateTime? desde;
  final DateTime? hasta;
  final ValueChanged<String?> onEstadoChanged;
  final VoidCallback onDesdeTap;
  final VoidCallback onHastaTap;
  final bool isExporting;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona qué tipo de eventos deseas incluir en tu documento PDF.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Filtrar por Estado',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          initialValue: estadoReporte,
          items: const [
            DropdownMenuItem(value: 'Todas', child: Text('Resumen General (Todas)')),
            DropdownMenuItem(value: 'Completadas', child: Text('Solo Eventos Completados')),
            DropdownMenuItem(value: 'Pendientes', child: Text('Solo Eventos Pendientes')),
          ],
          onChanged: isExporting ? null : onEstadoChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isExporting ? null : onDesdeTap,
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
                onPressed: isExporting ? null : onHastaTap,
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