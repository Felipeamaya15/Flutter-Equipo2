import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/routes/app_routes.dart';

class WorkerDashboardPage extends StatefulWidget {
  const WorkerDashboardPage({super.key});

  @override
  State<WorkerDashboardPage> createState() => _WorkerDashboardPageState();
}

class _WorkerDashboardPageState extends State<WorkerDashboardPage> {
  int _selectedIndex = 0;

  static const Color primaryColor = Color(0xFF4A4B22);
  static const Color backgroundColor = Color(0xFFFAF9F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.eco, color: primaryColor, size: 28),
            const SizedBox(width: 8),
            const Text(
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('solicitudes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error crítico de red al conectar con Cloud Firestore.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final List<QueryDocumentSnapshot> solicitudes = snapshot.data?.docs ?? [];
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
      if (data['fecha_evento'] == null) return false;
      try {
         DateTime fecha = (data['fecha_evento'] as Timestamp).toDate();
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generando reporte... (Función en desarrollo)'),
                      backgroundColor: primaryColor,
                      duration: Duration(seconds: 2),
                    ),
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
    final activasDocs = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final String estado = (data['estado'] ?? '').toString().trim().toLowerCase();
      return estado != 'completado';
    }).toList();

    return _buildDashboardBlock(
      title: 'Prioridades operativas',
      icon: Icons.check_circle_outline_rounded,
      child: activasDocs.isEmpty
          ? const Padding(padding: EdgeInsets.all(16.0), child: Text('No hay solicitudes activas registradas.', style: TextStyle(fontSize: 16)))
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activasDocs.length > 3 ? 3 : activasDocs.length,
              itemBuilder: (context, index) {
                final data = activasDocs[index].data() as Map<String, dynamic>;
                final docId = activasDocs[index].id;
                final String usuarioAsignado = data['usuarioAsignado'] ?? 'Sin asignar';
                final String emailCliente = data['email'] ?? 'Sin correo';
                
                // LEEMOS EL ESTADO REAL PARA MOSTRARLO
                final String estadoRaw = (data['estado'] ?? 'Pendiente').toString().trim();
                String estadoReal = 'Pendiente';
                if (estadoRaw.toLowerCase() == 'en proceso' || estadoRaw.toLowerCase() == 'en_proceso') {
                  estadoReal = 'En proceso';
                }
                
                final String rawTipo = data['tipoEvento'] ?? data['tipo_evento'] ?? '';
                final String tipoCatering = rawTipo.isNotEmpty ? rawTipo : 'Catering para $emailCliente';

                bool sinAsignar = usuarioAsignado.trim().toLowerCase() == 'sin asignar' || usuarioAsignado.trim().isEmpty;

                // ASIGNAMOS LA ETIQUETA BASADA EN EL ESTADO REAL
                String etiqueta = sinAsignar ? 'Por Tomar' : estadoReal;
                Color colorEtiqueta = sinAsignar ? Colors.orange : (estadoReal == 'En proceso' ? Colors.blue : Colors.teal);

                return _buildPriorityItem(
                  title: tipoCatering,
                  subtitle: 'Cliente: $emailCliente',
                  tag: etiqueta,
                  tagColor: colorEtiqueta,
                  trailingAction: sinAsignar
                      ? TextButton(
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance.collection('solicitudes').doc(docId).update({
                                'usuarioAsignado': 'Coordinador General',
                                'estado': 'En proceso'
                              });
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('¡Tarea tomada con éxito!'), backgroundColor: Colors.green),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
                              );
                            }
                          },
                          child: const Text('Tomar', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                        )
                      : const Icon(Icons.check, color: Colors.green),
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
                : ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;
                      final String folio = data['folio'] ?? docId.substring(0, 5).toUpperCase();
                      final String usuarioAsignado = data['usuarioAsignado'] ?? 'Sin asignar';
                      final String email = data['email'] ?? 'No registrado';
                      final String phone = data['phone'] ?? 'No registrado';

                      final String estadoRaw = (data['estado'] ?? 'Pendiente').toString().trim().toLowerCase();
                      String estadoValido = 'Pendiente';
                      if (estadoRaw == 'en proceso' || estadoRaw == 'en_proceso') estadoValido = 'En proceso';
                      else if (estadoRaw == 'completado') estadoValido = 'Completado';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Folio: #$folio', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                                    const SizedBox(height: 6),
                                    Text('Cliente: $email', style: const TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
                                    Text('Teléfono: $phone', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text('Encargado: $usuarioAsignado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: estadoValido, 
                                items: const [
                                  DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                                  DropdownMenuItem(value: 'En proceso', child: Text('En proceso')),
                                  DropdownMenuItem(value: 'Completado', child: Text('Completado')),
                                ],
                                onChanged: (nuevoEstado) async {
                                  if (nuevoEstado != null) {
                                    try {
                                      await FirebaseFirestore.instance.collection('solicitudes').doc(docId).update({'estado': nuevoEstado});
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Estado actualizado correctamente'), backgroundColor: Colors.green),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error al cambiar estado: $e'), backgroundColor: Colors.red),
                                      );
                                    }
                                  }
                                },
                              )
                            ],
                          ),
                        ),
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
      return data['fecha_evento'] != null;
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
                      final DateTime fecha = (data['fecha_evento'] as Timestamp).toDate();
                      final String folio = data['folio'] ?? docId.substring(0, 5).toUpperCase();
                      final String emailCliente = data['email'] ?? 'Sin correo';
                      
                      final String rawTipo = data['tipoEvento'] ?? data['tipo_evento'] ?? '';
                      final String tipoCatering = rawTipo.isNotEmpty ? rawTipo : 'Catering para $emailCliente';

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
                                  Text('Fecha: ${fecha.day}/${fecha.month}/${fecha.year}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
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