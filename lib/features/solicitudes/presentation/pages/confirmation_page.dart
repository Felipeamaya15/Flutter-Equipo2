import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ConfirmationPage extends StatelessWidget {
  final String folio;
  final String email;
  final Map<String, dynamic> datos; 

  const ConfirmationPage({
    super.key, 
    required this.folio, 
    required this.email,
    this.datos = const {}, 
  });

  Future<void> _generarYDescargarPDF(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generando resumen detallado...')),
      );

      final doc = pw.Document();

      String fechaStr = 'No definida';
      if (datos['fechaEvento'] != null) {
        final fecha = datos['fechaEvento'] as DateTime;
        fechaStr = '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';}

      String preferenciasMenu = (datos['preferenciasMenu'] as List<dynamic>?)?.join(', ') ?? 'Ninguna';
      String restricciones = (datos['restriccionesAlimentarias'] as List<dynamic>?)?.join(', ') ?? 'Ninguna';
      

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('Productora Intercultural SpA', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text('Resumen de Solicitud de Cotización', style: const pw.TextStyle(fontSize: 16, color: PdfColors.green800)),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Folio de Seguimiento: #$folio', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 10),

                pw.Text('1. DATOS DEL CLIENTE', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.SizedBox(height: 5),
                pw.Text('Tipo de Cliente: ${datos['tipoCliente'] ?? 'No especificado'}'),
                pw.Text('Nombre / Razón Social: ${datos['nombreCliente'] ?? 'No especificado'}'),
                pw.Text('RUT: ${datos['rutCliente'] ?? 'No especificado'}'),
                pw.Text('Correo Electrónico: ${datos['emailCliente'] ?? email}'),
                pw.Text('Teléfono: ${datos['telefonoCliente'] ?? 'No especificado'}'),

                pw.Text('2. LOGÍSTICA DEL EVENTO', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.SizedBox(height: 5),
                pw.Text('Tipo de Evento: ${datos['tipoEvento'] ?? 'No especificado'}'),
                pw.Text('Fecha Programada: $fechaStr'),
                pw.Text('Horario: ${datos['horaInicio'] ?? '--:--'} a ${datos['horaTermino'] ?? '--:--'}'),
                pw.Text('Cantidad de Asistentes: ${datos['cantidadAsistentes'] ?? '0'}'),
                pw.Text('Lugar: ${datos['lugarEvento'] ?? 'No especificado'}'),
                pw.Text('Tipo de Espacio: ${datos['tipoEspacio'] ?? 'No especificado'}'),
                pw.SizedBox(height: 15),

                pw.Text('3. PROPUESTA GASTRONÓMICA', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.SizedBox(height: 5),
                pw.Text('Formato de Servicio: ${datos['formatoServicio'] ?? 'No especificado'}'),
                pw.Text('Preferencias de Menú: $preferenciasMenu'),
                pw.Text('Restricciones Alimentarias: $restricciones'),
                if (datos['detallesEspeciales'] != null && datos['detallesEspeciales'].toString().isNotEmpty) ...[
                  pw.SizedBox(height: 5),
                  pw.Text('Detalles Especiales:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${datos['detallesEspeciales']}'),
                ],
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'Cotizacion_$folio.pdf',
      );
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, double value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 120),
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Solicitud Enviada con Éxito!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4A4B22)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text('Folio de seguimiento: #$folio', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
              const SizedBox(height: 8),
              Text(
                'Hemos enviado un desglose estimativo al correo:\n$email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => _generarYDescargarPDF(context),
                icon: const Icon(Icons.download),
                label: const Text('Descargar Resumen PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A4B22), 
                  side: const BorderSide(color: Color(0xFF4A4B22)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4B22),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text('Volver al Inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}