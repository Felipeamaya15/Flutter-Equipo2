import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CotizacionDocumentView extends StatelessWidget {
  final DocumentSnapshot solicitudDoc;

  const CotizacionDocumentView({super.key, required this.solicitudDoc});
  
  Future<void> _generarYDescargarPDF(BuildContext context, Map<String, dynamic> datos, String folio, String fechaStr, String encargado) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generando documento PDF...')),
      );

      final doc = pw.Document();

      String preferenciasMenu = 'Ninguna';
      if (datos['preferenciasMenu'] != null) {
        preferenciasMenu = (datos['preferenciasMenu'] as List<dynamic>).join(', ');
      }

      String restricciones = 'Ninguna';
      if (datos['restriccionesAlimentarias'] != null) {
        restricciones = (datos['restriccionesAlimentarias'] as List<dynamic>).join(', ');
      }

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('Productora Intercultural SpA', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF4A4B22))),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text('Detalle de Solicitud de Cotización', style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Folio de Seguimiento: #$folio', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('Estado Actual: ${datos['estado'] ?? 'Pendiente'}', style: pw.TextStyle(fontSize: 12)),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 10),

                pw.Text('1. DATOS DEL CLIENTE', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.SizedBox(height: 5),
                pw.Text('Tipo de Cliente: ${datos['tipoCliente'] ?? 'No especificado'}'),
                pw.Text('Nombre / Razón Social: ${datos['nombreCliente'] ?? 'No especificado'}'),
                pw.Text('RUT: ${datos['rutCliente'] ?? 'No especificado'}'),
                pw.Text('Correo Electrónico: ${datos['emailCliente'] ?? 'No especificado'}'),
                pw.Text('Teléfono: ${datos['telefonoCliente'] ?? 'No especificado'}'),
                pw.SizedBox(height: 15),

                pw.Text('2. LOGÍSTICA DEL EVENTO', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.SizedBox(height: 5),
                pw.Text('Tipo de Evento: ${datos['nombreEvento'] ?? 'No especificado'}'),
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
                if (datos['detallesEspeciales'] != null && datos['detallesEspeciales'].toString().trim().isNotEmpty) ...[
                  pw.SizedBox(height: 5),
                  pw.Text('Detalles Especiales:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${datos['detallesEspeciales']}'),
                ],
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.grey400),
                pw.Text('Ejecutivo Asignado: $encargado', style: pw.TextStyle(fontSize: 11, color: PdfColors.grey800)),
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
    final data = solicitudDoc.data() as Map<String, dynamic>? ?? {};

    final String folio = data['folio'] ?? '-----';
    final String estado = data['estado'] ?? 'Pendiente';
    final String tipoCliente = data['tipoCliente'] ?? 'Persona Natural';
    final String encargado = data['usuarioAsignado'] ?? 'Sin asignar';

    String formatearHoraString(dynamic horaRaw){
      if (horaRaw == null || horaRaw.toString().isEmpty) return '--:--';
      final String horaStr = horaRaw.toString().trim();

      if (horaStr.contains(':')){
        final partes = horaStr.split(':');
        if(partes.length == 2) {
          final stringHora = InvalidPattern.match(partes[0]) ? '00' : partes[0].padLeft(2, '0');
          final stringMinuto = InvalidPattern.match(partes[1]) ? '00' : partes[1].padRight(2, '0');
          return '$stringHora:$stringMinuto';
        }
      } 
      return horaStr;
    }

    String fechaFormateada = 'No especificada';
    String fechaCortaParaPDF = 'No definida';
    if (data['fechaEvento'] != null && data['fechaEvento'] is Timestamp) {
      DateTime date = (data['fechaEvento'] as Timestamp).toDate();
      fechaFormateada = DateFormat('dd \'de\' MMMM, yyyy', 'es').format(date);
      fechaCortaParaPDF = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    const Color primaryColor = Color(0xFF4A4B22);
    const Color textDark = Color(0xFF2C2D15);
    const Color labelColor = Color(0xFF707155);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EL GUSTO ES NUESTRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Productora Intercultural SpA',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'FOLIO #$folio',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              estado.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(Icons.person_outline, 'Información del Cliente', primaryColor),
                      const SizedBox(height: 12),
                      if (tipoCliente == 'Empresa / Corp') ...[
                        _buildDocumentRow('Razón Social', data['nombreCliente'], textDark, labelColor),
                        _buildDocumentRow('RUT Empresa', data['rutCliente'], textDark, labelColor),
                        _buildDocumentRow('Giro Comercial', data['giroEmpresa'], textDark, labelColor),
                        _buildDocumentRow('Dirección Fiscal', data['direccionComercial'], textDark, labelColor),
                        _buildDocumentRow('Contacto Coordinador', data['nombreContactoEmpresa'], textDark, labelColor),
                      ] else ...[
                        _buildDocumentRow('Nombre Completo', data['nombreCliente'], textDark, labelColor),
                        _buildDocumentRow('RUT', data['rutCliente'], textDark, labelColor),
                      ],
                      _buildDocumentRow('Correo Electrónico', data['emailCliente'], textDark, labelColor),
                      _buildDocumentRow('Teléfono Móvil', data['telefonoCliente'], textDark, labelColor),
                      const Divider(height: 40, thickness: 1, color: Color(0xFFEFEFEA)),
                      _buildSectionHeader(Icons.calendar_today_outlined, 'Detalles de la Logística', primaryColor),
                      const SizedBox(height: 12),
                      _buildDocumentRow('Tipo de Evento', data['nombreEvento'], textDark, labelColor),
                      _buildDocumentRow('Fecha Programada', fechaFormateada, textDark, labelColor),
                      _buildDocumentRow('Horario', '${formatearHoraString(data['horaInicio'])} a ${formatearHoraString(data['horaTermino'])} hrs', textDark, labelColor),
                      _buildDocumentRow('Cantidad Asistentes', '${data['cantidadAsistentes'] ?? 0} personas', textDark, labelColor),
                      _buildDocumentRow('Lugar/Ubicación', data['lugarEvento'], textDark, labelColor),
                      _buildDocumentRow('Entorno / Espacio', data['tipoEspacio'], textDark, labelColor),
                      const Divider(height: 40, thickness: 1, color: Color(0xFFEFEFEA)),
                      _buildSectionHeader(Icons.restaurant_menu_outlined, 'Propuesta Gastronómica', primaryColor),
                      const SizedBox(height: 12),
                      _buildDocumentRow('Formato de Servicio', data['formatoServicio'], textDark, labelColor),
                      _buildDocumentRow('Menús Temáticos', _parseListOrString(data['preferenciasMenu']), textDark, labelColor),
                      _buildDocumentRow('Restricciones/Alergias', _parseListOrString(data['restriccionesAlimentarias']), textDark, labelColor),
                      
                      const SizedBox(height: 12),
                      _buildEspecialNotesBlock('Requerimientos Especiales y Notas del Chef:', data['detallesEspeciales'], textDark, labelColor),
          
                      const Divider(height: 40, thickness: 1, color: Color(0xFFEFEFEA)),
          
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ejecutivo Asignado',
                                style: TextStyle(color: labelColor, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                encargado,
                                style: const TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            'El Gusto es Nuestro',
                            style: TextStyle(color: labelColor.withValues(alpha: 0.6), fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _generarYDescargarPDF(context, data, folio, fechaCortaParaPDF, encargado),
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Descargar Copia en PDF', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color accentColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: accentColor),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
      ],
    );
  }

  Widget _buildDocumentRow(String label, dynamic value, Color textColor, Color labelColor) {
    final String displayValue = (value == null || value.toString().isEmpty) ? 'No registrado' : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: TextStyle(color: labelColor, fontSize: 14, fontWeight: FontWeight.w400)),
          ),
          Expanded(
            child: Text(displayValue, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEspecialNotesBlock(String title, dynamic value, Color textColor, Color labelColor) {
    final String content = (value == null || value.toString().trim().isEmpty) ? 'Sin requerimientos especiales adicionales.' : value.toString();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEBEBE0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: labelColor, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(content, style: TextStyle(color: textColor, fontSize: 15, height: 1.4, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  String _parseListOrString(dynamic data) {
    if (data == null) return 'Ninguno';
    if (data is List) {
      if (data.isEmpty) return 'Ninguno';
      return data.join(', ');
    }
    return data.toString();
  }
}

class InvalidPattern {
  static bool match(String s) => RegExp(r'[a-zA-Z]').hasMatch(s);
}