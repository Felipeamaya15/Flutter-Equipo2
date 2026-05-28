import 'package:flutter/material.dart';

class BarGraficoWidget extends StatelessWidget {
  final int solicitudesPorTipo;
  final int totalSolicitudes;
  final int asignadas;
  final int sinAsignar;

  const BarGraficoWidget({
    super.key,
    required this.solicitudesPorTipo,
    required this.totalSolicitudes,
    required this.asignadas,
    required this.sinAsignar,
  });

  @override
  Widget build(BuildContext context) {
    double porcAsignadas = totalSolicitudes > 0 ? (asignadas / totalSolicitudes) : 0;
    double porcSinAsignar = totalSolicitudes > 0 ? (sinAsignar / totalSolicitudes) : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Control de Asignación Operativa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A4B22)),
          ),
          const Text(
            'Trabajo tomado por el equipo vs. trabajos pendientes por asignar.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          _buildBarraMetrica(
            label: 'Solicitudes Asignadas',
            cantidad: asignadas,
            factor: porcAsignadas,
            colorBarra: const Color(0xFF4A4B22),
          ),
          const SizedBox(height: 16),

          _buildBarraMetrica(
            label: 'Solicitudes por Asignar (Pendientes)',
            cantidad: sinAsignar,
            factor: porcSinAsignar,
            colorBarra: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildBarraMetrica({
    required String label,
    required int cantidad,
    required double factor,
    required Color colorBarra,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
            Text('$cantidad unidad(es)', style: TextStyle(color: colorBarra, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
            ),
            FractionallySizedBox(
              widthFactor: factor,
              child: Container(
                height: 12,
                decoration: BoxDecoration(color: colorBarra, borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ],
        )
      ],
    );
  }
}