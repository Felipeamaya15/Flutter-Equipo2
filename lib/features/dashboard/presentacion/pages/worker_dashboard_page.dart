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
  static const Color sidebarColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          Container(
            width: 240,
            color: sidebarColor,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.eco, color: primaryColor, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Productora\nIntercultural\nSpA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildSidebarItem(Icons.grid_view_rounded, 'Dashboard', isSelected: _selectedIndex == 0, onTap: () => setState(() => _selectedIndex = 0)),
                _buildSidebarItem(Icons.assignment_outlined, 'Solicitudes', isSelected: _selectedIndex == 1, onTap: () => setState(() => _selectedIndex = 1)),
                _buildSidebarItem(Icons.calendar_today_outlined, 'Agenda', isSelected: _selectedIndex == 2, onTap: () => setState(() => _selectedIndex = 2)),
                const Spacer(),
                _buildSidebarItem(
                  Icons.logout_rounded,
                  'Cerrar Sesión',
                  onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('solicitudes').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error crítico de red al conectar con Cloud Firestore.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }

                final List<QueryDocumentSnapshot> solicitudes = snapshot.data?.docs ?? [];

                switch (_selectedIndex) {
                  case 0:
                    return _buildDashboardTab(solicitudes);
                  case 1:
                    return _buildSolicitudesTab(solicitudes);
                  case 2:
                    return _buildAgendaTab(solicitudes);
                  default:
                    return _buildDashboardTab(solicitudes);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(List<QueryDocumentSnapshot> docs) {
    int totalSolicitudes = docs.length;
    int pendientesAsignar = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final String asignado = (data['usuarioAsignado'] ?? 'Sin asignar').toString().trim().toLowerCase();
      return asignado == 'sin asignar';
    }).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildHeader('Panel trabajador', 'Gestión diaria de solicitudes, eventos y tareas del equipo.'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
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
          Row(
            children: [
              _buildMetricCard('Solicitudes activas', '$totalSolicitudes', '+4 hoy', Icons.assignment_outlined, Colors.teal.shade50),
              const SizedBox(width: 16),
              _buildMetricCard('Eventos de la semana', '7', '3 en montaje', Icons.calendar_today_rounded, Colors.orange.shade50),
              const SizedBox(width: 16),
              _buildMetricCard('Solicitudes por asignar', '$pendientesAsignar', 'Requiere operador', Icons.gavel_rounded, Colors.red.shade50),
              const SizedBox(width: 16),
              _buildMetricCard('Satisfacción', '94%', 'último mes', Icons.verified_outlined, Colors.green.shade50),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: _buildDashboardBlock(
                  title: 'Prioridades operativas',
                  icon: Icons.check_circle_outline_rounded,
                  child: docs.isEmpty
                      ? const Padding(padding: EdgeInsets.all(16.0), child: Text('No hay solicitudes registradas.', style: TextStyle(fontSize: 16)))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length > 3 ? 3 : docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            final docId = docs[index].id;
                            final String usuarioAsignado = data['usuarioAsignado'] ?? 'Sin asignar';
                            final String emailCliente = data['email'] ?? 'Sin correo';
                            
                            final String rawTipo = data['tipoEvento'] ?? data['tipo_evento'] ?? '';
                            final String tipoCatering = rawTipo.isNotEmpty 
                                ? rawTipo 
                                : 'Catering para $emailCliente';

                            return _buildPriorityItem(
                              title: tipoCatering,
                              subtitle: 'Cliente: $emailCliente',
                              tag: usuarioAsignado.trim().toLowerCase() == 'sin asignar' ? 'Por Tomar' : 'Asignado',
                              tagColor: usuarioAsignado.trim().toLowerCase() == 'sin asignar' ? Colors.orange : Colors.teal,
                              trailingAction: usuarioAsignado.trim().toLowerCase() == 'sin asignar'
                                  ? TextButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance.collection('solicitudes').doc(docId).update({
                                          'usuarioAsignado': 'Coordinador General',
                                          'estado': 'En proceso'
                                        });
                                      },
                                      child: const Text('Tomar Tarea', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                    )
                                  : const Icon(Icons.check, color: Colors.green),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: _buildDashboardBlock(
                  title: 'Agenda de hoy',
                  icon: Icons.access_time_rounded,
                  child: Column(
                    children: [
                      _buildAgendaItem('Degustación cliente', 'Sala norte', '09:00', Colors.amber),
                      _buildAgendaItem('Despacho insumos', 'Bodega central', '13:00', Colors.green),
                      _buildAgendaItem('Cierre de propuesta', 'Fundación Raíces', '16:30', Colors.brown),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSolicitudesTab(List<QueryDocumentSnapshot> docs) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Bandeja de Solicitudes', 'Listado maestro de asignaciones de formularios y control de tracking interno .'),
          const SizedBox(height: 24),
          Expanded(
            child: docs.isEmpty
                ? const Center(child: Text('No existen solicitudes registradas en Firestore.', style: TextStyle(fontSize: 16)))
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
                      if (estadoRaw == 'en proceso' || estadoRaw == 'en_proceso') {
                        estadoValido = 'En proceso';
                      } else if (estadoRaw == 'completado') {
                        estadoValido = 'Completado';
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Formulario Folio: #$folio', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                                  const SizedBox(height: 6),
                                  Text('Cliente: $email', style: const TextStyle(fontSize: 16)),
                                  Text('Teléfono: $phone', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text('Encargado: $usuarioAsignado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                                ],
                              ),
                              DropdownButton<String>(
                                value: estadoValido, 
                                items: const [
                                  DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                                  DropdownMenuItem(value: 'En proceso', child: Text('En Proceso')),
                                  DropdownMenuItem(value: 'Completado', child: Text('Completado')),
                                ],
                                onChanged: (nuevoEstado) {
                                  if (nuevoEstado != null) {
                                    FirebaseFirestore.instance.collection('solicitudes').doc(docId).update({'estado': nuevoEstado});
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

  Widget _buildAgendaTab(List<QueryDocumentSnapshot> docs) {
    final eventosConFecha = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['fecha_evento'] != null;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Cronograma de Eventos', 'Fechas de ejecución programadas y sincronizadas desde el calendario (HU6).'),
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
                      final String tipoCatering = rawTipo.isNotEmpty 
                          ? rawTipo 
                          : 'Catering para $emailCliente';

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
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tipoCatering,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ejecución del evento: ${fecha.day}/${fecha.month}/${fecha.year}',
                                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            Text('Folio: #$folio', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
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
        Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1C1D0E))),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, {bool isSelected = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAF9F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey[600], size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryColor : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String trend, IconData icon, Color bg) {
    return Expanded(
      child: Container(
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
            Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardBlock({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)), 
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
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(tag, style: TextStyle(color: tagColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
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
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
        ],
      ),
    );
  }
}