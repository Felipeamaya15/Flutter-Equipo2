import 'package:flutter/material.dart';
import '../viewmodels/report_viewmodel.dart';
import '../widgets/pie_grafico.dart';
import '../widgets/bar_grafico.dart';
import '../widgets/cronograma_grafico.dart';
import 'package:provider/provider.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportViewModel>().initSnapshotListener();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Reporte Operativo',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Consumer<ReportViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A4B22)));
          }
          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(viewModel.errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
              ),
            );
          }
          if (viewModel.totalSolicitudes == 0) {
            return const Center(child: Text('No hay datos históricos para procesar gráficos.', style: TextStyle(fontSize: 16)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Métricas Consolidadas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1C1D0E))),
                const SizedBox(height: 4),
                Text('Total de cotizaciones analizadas en tiempo real: ${viewModel.totalSolicitudes}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 24),

                PieGraficoWidget(
                  pendientes: viewModel.pendientes,
                  enProceso: viewModel.enProceso,
                  completadas: viewModel.completadas,
                ),
                const SizedBox(height: 24),

                BarGraficoWidget(
                  solicitudesPorTipo: viewModel.totalSolicitudes, // Evita romper firmas existentes
                  totalSolicitudes: viewModel.totalSolicitudes,
                  asignadas: viewModel.solicitudesAsignadas,
                  sinAsignar: viewModel.solicitudesSinAsignar,
                ),
                const SizedBox(height: 24),

                CronogramaGraficoWidget(
                  eventosPorMes: viewModel.eventosPorMes,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}