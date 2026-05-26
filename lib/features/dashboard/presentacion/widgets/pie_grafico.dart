import 'package:flutter/material.dart';

class PieGraficoWidget extends StatelessWidget {
  final int pendientes;
  final int enProceso;
  final int completadas;

  const PieGraficoWidget({
    super.key,
    required this.pendientes,
    required this.enProceso,
    required this.completadas,
  });

  @override
  Widget build(BuildContext context) {
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
            'Distribución de Estados Operativos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A4B22)),
          ),
          const Text(
            'Visualización porcentual de flujo de cotizaciones.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                  painter: _PieGraficoPainter(
                    pendientes: pendientes,
                    enProceso: enProceso,
                    completadas: completadas,
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Pendientes ($pendientes)', Colors.amber),
                    const SizedBox(height: 8),
                    _buildLegendItem('En Proceso ($enProceso)', Colors.blue),
                    const SizedBox(height: 8),
                    _buildLegendItem('Completadas ($completadas)', Colors.green),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _PieGraficoPainter extends CustomPainter {
  final int pendientes;
  final int enProceso;
  final int completadas;

  _PieGraficoPainter({required this.pendientes, required this.enProceso, required this.completadas});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = (pendientes + enProceso + completadas).toDouble();
    if (total == 0) return;

    final double anglePendientes = (pendientes / total) * 2 * 3.141592653589793;
    final double angleEnProceso = (enProceso / total) * 2 * 3.141592653589793;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint paint = Paint()..style = PaintingStyle.fill;

    double startAngle = -3.141592653589793 / 2;

    paint.color = Colors.amber;
    canvas.drawArc(rect, startAngle, anglePendientes, true, paint);
    startAngle += anglePendientes;

    paint.color = Colors.blue;
    canvas.drawArc(rect, startAngle, angleEnProceso, true, paint);
    startAngle += angleEnProceso;

    paint.color = Colors.green;
    canvas.drawArc(rect, startAngle, (2 * 3.141592653589793) - anglePendientes - angleEnProceso, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}