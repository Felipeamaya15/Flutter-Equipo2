import 'package:flutter/material.dart';

class CronogramaGraficoWidget extends StatelessWidget {
  final Map<String, int> eventosPorMes;

  const CronogramaGraficoWidget({
    super.key,
    required this.eventosPorMes,
  });

  @override
  Widget build(BuildContext context) {
    int maxEventos = 0;
    for (var cantidad in eventosPorMes.values) {
      if (cantidad > maxEventos) maxEventos = cantidad;
    }

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
          const Row(
            children: [
              Icon(Icons.calendar_view_month_rounded, color: Color(0xFF4A4B22), size: 20),
              SizedBox(width: 8),
              Text(
                'Cantidad de Eventos Mensuales',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A4B22)),
              ),
            ],
          ),
          const Text(
            'Proyección cronológica basada en las fechas de los eventos programados.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          
          if (eventosPorMes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text('No hay eventos agendados en el calendario actualmente.', 
                  style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic)),
              ),
            )
          else
            Column(
              children: eventosPorMes.entries.map((entry) {
                double factor = maxEventos > 0 ? (entry.value / maxEventos) : 0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          entry.key, 
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 14,
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                            ),
                            FractionallySizedBox(
                              widthFactor: factor,
                              child: Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6B6C3B), Color(0xFF4A4B22)],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      Text(
                        '${entry.value} ev.', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}