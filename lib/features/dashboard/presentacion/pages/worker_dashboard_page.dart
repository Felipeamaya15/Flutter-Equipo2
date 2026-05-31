import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/solicitudes_provider.dart'; 
import 'generar_reporte_dialog.dart';

class WorkerDashboardPage extends StatefulWidget {
  const WorkerDashboardPage({super.key});

  @override
  State<WorkerDashboardPage> createState() => _WorkerDashboardPageState();
}

class _WorkerDashboardPageState extends State<WorkerDashboardPage> {
  int _selectedIndex = 0;

  static const Color primaryColor = Color(0xFF4A4B22);
  static const Color backgroundColor = Color(0xFFFAF9F6);

Widget _buildSolicitudCard(QueryDocumentSnapshot doc, BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final docId = doc.id;
    final String folio = data['folio'] ?? docId.substring(0, 5).toUpperCase();
    final String usuarioAsignado = data['usuarioAsignado'] ?? 'Sin asignar';
    final String email = data['emailCliente'] ?? 'No registrado';
    final String phone = data['telefonoCliente'] ?? 'No registrado';

    final String estadoRaw = (data['estado'] ?? 'Pendiente').toString().trim().toLowerCase();
    String estadoValido = 'Pendiente';
    
    if (estadoRaw == 'en proceso' || estadoRaw == 'en_proceso') {
      estadoValido = 'En proceso';
    } else if (estadoRaw == 'completado') {
      estadoValido = 'Completado';
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // 1. Guardamos la solicitud cliqueada en el Provider
          // Usamos listen: false porque estamos dentro de un evento de toque, no dibujando UI aquí
          Provider.of<SolicitudesProvider>(context, listen: false).seleccionarSolicitud(doc);
          
          // 2. Navegamos a la pantalla del formulario que configuramos como "Modo Detalle"
          Navigator.pushNamed(context, AppRoutes.solicitudForm);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxWidth < 560;

              final Widget estadoSelector = SizedBox(
                width: compact ? double.infinity : 170,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: estadoValido,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                    DropdownMenuItem(value: 'En proceso', child: Text('En proceso')),
                    DropdownMenuItem(value: 'Completado', child: Text('Completado')),
                  ],
                  onChanged: (nuevoEstado) async {
                    if (nuevoEstado != null) {
                      try {
                        await FirebaseFirestore.instance.collection('solicitudes').doc(docId).update({'estado': nuevoEstado});
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Estado actualizado correctamente'), backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al cambiar estado: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
              );

              if (compact) {
                return Column(
                  mainAxisSize: MainAxisSize.min, 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Folio: #$folio', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                    const SizedBox(height: 8),
                    Text('Cliente: $email', style: const TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('Teléfono: $phone', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('Encargado: $usuarioAsignado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                    const SizedBox(height: 16),
                    estadoSelector,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, 
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Folio: #$folio', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                        const SizedBox(height: 6),
                        Text('Cliente: $email', style: const TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('Teléfono: $phone', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 10),
                        Text('Encargado: $usuarioAsignado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  estadoSelector,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Row(
          children: [
            Icon(Icons.eco, color: primaryColor, size: 28),
            SizedBox(width: 8),
            Text(
              'Productora Intercultural SpA',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Cerrar Sesión',
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Solicitudes'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Agenda'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.solicitudForm);
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<SolicitudesProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return const Center(child: Text('Error crítico de red al conectar con Cloud Firestore.'));
          }
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final List<QueryDocumentSnapshot> solicitudes = provider.solicitudes;
          final bool isMobile = MediaQuery.of(context).size.width < 800; 
          final double paddingValue = isMobile ? 16.0 : 32.0;

          switch (_selectedIndex) {
            case 0:
              return _buildDashboardTab(solicitudes, isMobile, paddingValue);
            case 1:
              return _buildSolicitudesTab(solicitudes, paddingValue);
            case 2:
              return _buildAgendaTab(solicitudes, paddingValue);
            default:
              return _buildDashboardTab(solicitudes, isMobile, paddingValue);
          }
        },
      ),
    );
  }

  Widget _buildDashboardTab(List<QueryDocumentSnapshot> docs, bool isMobile, double paddingValue) {
    int solicitudesActivas = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final String estado = (data['estado'] ?? 'Pendiente').toString().trim().toLowerCase();
      return estado != 'completado'; 
    }).length;

    int pendientesAsignar = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final String estado = (data['estado'] ?? '').toString().trim().toLowerCase();
      if (estado == 'completado') return false; 

      final String asignado = (data['usuarioAsignado'] ?? '').toString().trim().toLowerCase();
      return asignado.isEmpty || asignado == 'sin asignar' || asignado == 'null';
    }).length;

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1)); 
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6)); 
    
    DateTime start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day); 
    DateTime end = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59); 

    int eventosSemanaCount = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['fechaEvento'] == null) return false; 
      try {
         DateTime fecha = (data['fechaEvento'] as Timestamp).toDate();
         return fecha.isAfter(start.subtract(const Duration(seconds: 1))) && 
                fecha.isBefore(end.add(const Duration(seconds: 1)));
      } catch(e) {
         return false; 
      }
    }).length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(paddingValue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildHeader('Panel trabajador', 'Gestión diaria de solicitudes, eventos y tareas del equipo.'),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const GenerarReporteDialog(),
                  );
                },
                icon: const Icon(Icons.analytics_outlined, size: 18),
                label: const Text('Reporte', style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          isMobile
              ? Column(
                  children: [
                    _buildMetricCard('Solicitudes activas', '$solicitudesActivas', 'En curso', Icons.assignment_outlined, Colors.teal.shade50, double.infinity),
                    const SizedBox(height: 16),
                    _buildMetricCard('Eventos de la semana', '$eventosSemanaCount', 'Esta semana', Icons.calendar_today_rounded, Colors.orange.shade50, double.infinity),
                    const SizedBox(height: 16),
                    _buildMetricCard('Solicitudes por asignar', '$pendientesAsignar', 'Requiere operador', Icons.gavel_rounded, Colors.red.shade50, double.infinity),
                    const SizedBox(height: 16),
                    _buildMetricCard('Satisfacción', '94%', 'último mes', Icons.verified_outlined, Colors.green.shade50, double.infinity),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildMetricCard('Solicitudes activas', '$solicitudesActivas', 'En curso', Icons.assignment_outlined, Colors.teal.shade50, null)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMetricCard('Eventos de la semana', '$eventosSemanaCount', 'Esta semana', Icons.calendar_today_rounded, Colors.orange.shade50, null)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMetricCard('Solicitudes por asignar', '$pendientesAsignar', 'Requiere operador', Icons.gavel_rounded, Colors.red.shade50, null)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMetricCard('Satisfacción', '94%', 'último mes', Icons.verified_outlined, Colors.green.shade50, null)),
                  ],
                ),
          const SizedBox(height: 32),
          
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPrioridadesBlock(docs),
                    const SizedBox(height: 24),
                    _buildAgendaHoyBlock(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildPrioridadesBlock(docs)),
                    const SizedBox(width: 24),
                    Expanded(flex: 3, child: _buildAgendaHoyBlock()),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildPrioridadesBlock(List<QueryDocumentSnapshot> docs) {
    final solicitudesAbiertas = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final String estado = (data['estado'] ?? 'Pendiente').toString().trim().toLowerCase();
    
      return estado != 'completado';
    }).toList();

    solicitudesAbiertas.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;
      final Timestamp fechaA = dataA['creado_en'] ?? Timestamp.now();
      final Timestamp fechaB = dataB['creado_en'] ?? Timestamp.now();

      return fechaA.compareTo(fechaB);
    });

    return _buildDashboardBlock(
      title: 'Prioridades operativas',
      icon: Icons.check_circle_outline_rounded,
      child: solicitudesAbiertas.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  '¡Excelente! Todas las solicitudes están completadas.',
                  style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: solicitudesAbiertas.length > 3 ? 3 : solicitudesAbiertas.length,
              itemBuilder: (context, index) {
                final data = solicitudesAbiertas[index].data() as Map<String, dynamic>;
                final String emailCliente = data['emailCliente'] ?? 'Sin correo';
                final String rawTipo = data['nombreEvento'] ?? '';
                final String tipoCatering = rawTipo.isNotEmpty ? rawTipo : 'Logística para $emailCliente';
                final Timestamp creadoEn = data['creado_en'] ?? Timestamp.now();
                final DateTime fechaCreacion = creadoEn.toDate();
                final Duration tiempoEspera = DateTime.now().difference(fechaCreacion);
                bool esMuyAntigua = tiempoEspera.inHours >= 24;
                final String estadoRaw = (data['estado'] ?? 'Pendiente').toString().trim();
                String etiqueta = estadoRaw.toLowerCase() == 'en proceso' || estadoRaw.toLowerCase() == 'en_proceso' ? 'En proceso' : 'Pendiente';

                return _buildPriorityItem(
                  title: tipoCatering,
                  subtitle: esMuyAntigua 
                      ? '⚠️ Tiempo de asignación excedido' 
                      : 'Cliente: $emailCliente',
                  tag: esMuyAntigua ? 'ALTA' : etiqueta,
                  tagColor: esMuyAntigua ? Colors.redAccent : (etiqueta == 'En proceso' ? Colors.blue : Colors.orange),
                  trailingAction: const SizedBox.shrink(),
                );
              },
            ),
    );
  }

  Widget _buildAgendaHoyBlock() {
    return _buildDashboardBlock(
      title: 'Agenda de hoy',
      icon: Icons.access_time_rounded,
      child: Column(
        children: [
          _buildAgendaItem('Degustación cliente', 'Sala norte', '09:00', Colors.amber),
          _buildAgendaItem('Despacho insumos', 'Bodega central', '13:00', Colors.green),
          _buildAgendaItem('Cierre de propuesta', 'Fund. Raíces', '16:30', Colors.brown),
        ],
      ),
    );
  }

  Widget _buildSolicitudesTab(List<QueryDocumentSnapshot> docs, double paddingValue) {
    return Padding(
      padding: EdgeInsets.all(paddingValue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Bandeja de Solicitudes', 'Listado maestro de asignaciones de formularios.'),
          const SizedBox(height: 24),
          Expanded(
            child: docs.isEmpty
                ? const Center(child: Text('No existen solicitudes registradas.', style: TextStyle(fontSize: 16)))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 820) {
                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 450,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 2.3,
                          ),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            return _buildSolicitudCard(docs[index], context);
                          },
                        );
                      }

                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildSolicitudCard(docs[index], context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaTab(List<QueryDocumentSnapshot> docs, double paddingValue) {
    final eventosConFecha = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['fechaEvento'] != null;
    }).toList();

    return Padding(
      padding: EdgeInsets.all(paddingValue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Cronograma de Eventos', 'Fechas de ejecución programadas.'),
          const SizedBox(height: 24),
          Expanded(
            child: eventosConFecha.isEmpty
                ? const Center(child: Text('No hay eventos registrados con fechas válidas.', style: TextStyle(fontSize: 16)))
                : ListView.builder(
                    itemCount: eventosConFecha.length,
                    itemBuilder: (context, index) {
                      final data = eventosConFecha[index].data() as Map<String, dynamic>;
                      final docId = eventosConFecha[index].id;
                      final DateTime fecha = (data['fechaEvento'] as Timestamp).toDate();
                      final String folio = data['folio'] ?? docId.substring(0, 5).toUpperCase();
                      final String emailCliente = data['emailCliente'] ?? 'Sin correo';
                      final String tipoCatering = data['nombreEvento'] ?? 'Logística de Evento';

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: primaryColor.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.calendar_month, color: primaryColor, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tipoCatering, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Fecha: ${fecha.day}/${fecha.month}/${fecha.year} - $emailCliente', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                ],
                              ),
                            ),
                            Text('#$folio', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1C1D0E))),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String trend, IconData icon, Color bg, double? width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              Text(trend, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDashboardBlock({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)), 
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildPriorityItem({required String title, required String subtitle, required String tag, required Color tagColor, required Widget trailingAction}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: tagColor.withAlpha(26), borderRadius: BorderRadius.circular(4)),
                child: Text(tag, style: TextStyle(color: tagColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 4),
              trailingAction,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaItem(String title, String location, String time, Color dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
        ],
      ),
    );
  }
}