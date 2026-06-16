import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/solicitudes_provider.dart'; 
import 'generar_reporte_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_equipo2/features/auth/presentation/providers/auth_provider.dart';

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
    Color colorEstado = Colors.orange; 
    
    if (estadoRaw == 'en proceso' || estadoRaw == 'en_proceso') {
      estadoValido = 'En proceso';
      colorEstado = Colors.blue;
    } else if (estadoRaw == 'completado') {
      estadoValido = 'Completado';
      colorEstado = Colors.green;
    }

    final List<String> opcionesEstado = ['Pendiente', 'En proceso', 'Completado'];

    return Card(
      elevation: 0, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200), 
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Provider.of<SolicitudesProvider>(context, listen: false).seleccionarSolicitud(doc);
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
                  icon: Icon(Icons.arrow_drop_down, color: colorEstado),
                  
                  dropdownColor: Colors.grey.shade100, 
                  
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: colorEstado.withAlpha(20), 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colorEstado.withAlpha(50))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colorEstado.withAlpha(50))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colorEstado, width: 2)),
                  ),
                  
                  selectedItemBuilder: (BuildContext context) {
                    return opcionesEstado.map<Widget>((String item) {
                      return Text(
                        item,
                        style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 14),
                      );
                    }).toList();
                  },

                  items: opcionesEstado.map((String val) {
                    return DropdownMenuItem(
                      value: val, 
                      child: Text(
                        val, 
                        style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500, fontSize: 14)
                      ),
                    );
                  }).toList(),

                  onChanged: (nuevoEstado) async {
                    if (nuevoEstado != null && nuevoEstado != estadoValido) {
                      try {
                        await FirebaseFirestore.instance.collection('solicitudes').doc(docId).update({'estado': nuevoEstado});
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado actualizado correctamente'), backgroundColor: Colors.green));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cambiar estado: $e'), backgroundColor: Colors.red));
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_rounded, color: primaryColor, size: 30),
            tooltip: 'Menú de Usuario',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            onSelected: (String opcion) async {
              if (opcion == 'perfil') {
                _mostrarDialogoPerfil(context);
              } else if (opcion == 'password') {
                _mostrarDialogoCambiarPassword(context);
              } else if (opcion == 'logout') {
                _mostrarConfirmacionLogout(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'perfil',
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded, color: Colors.grey.shade700, size: 22),
                    const SizedBox(width: 12),
                    const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'password',
                child: Row(
                  children: [
                    Icon(Icons.lock_reset_rounded, color: Colors.grey.shade700, size: 22),
                    const SizedBox(width: 12),
                    const Text('Cambiar Clave', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                    SizedBox(width: 12),
                    Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Provider.of<SolicitudesProvider>(context, listen: false).clearSeleccion();
          Navigator.pushNamed(context, AppRoutes.solicitudForm);
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Nueva Solicitud', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<SolicitudesProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return const Center(child: Text('Error crítico de red al conectar con Cloud Firestore.'));
          }
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final List<QueryDocumentSnapshot> solicitudes = provider.solicitudesFiltradas;
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
      return estado != 'completado' && estado.isNotEmpty; 
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
         return fecha.isAfter(start.subtract(const Duration(seconds: 1))) && fecha.isBefore(end.add(const Duration(seconds: 1)));
      } catch(e) { return false; }
    }).length;

    final double spacing = isMobile ? 16.0 : 24.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(paddingValue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: spacing, runSpacing: spacing,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildHeader('Panel trabajador', 'Gestión diaria de solicitudes, eventos y tareas del equipo.'),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(context: context, builder: (context) => const GenerarReporteDialog());
                },
                icon: const Icon(Icons.analytics_outlined, size: 18),
                label: const Text('Reporte', style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor, side: const BorderSide(color: primaryColor), 
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                ),
              ),
            ],
          ),
          SizedBox(height: spacing * 1.5), 
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('En proceso', '$solicitudesActivas', 'Activas', Icons.assignment_outlined, Colors.teal.shade50, null),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: _buildMetricCard('Eventos', '$eventosSemanaCount', 'Semana', Icons.calendar_today_rounded, Colors.orange.shade50, null),
              ),
            ],
          ),
          
          SizedBox(height: spacing * 1.5), 
          SizedBox(
            width: double.infinity,
            child: _buildProximosEventosBlock(docs),
          ),
        ],
      ),
    );
  }

  Widget _buildProximosEventosBlock(List<QueryDocumentSnapshot> docs) {
    final eventosFuturos = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final String estado = (data['estado'] ?? '').toString().trim().toLowerCase();
      return estado != 'completado' && data['fechaEvento'] != null;
    }).toList();

    eventosFuturos.sort((a, b) {
      final Timestamp fechaA = (a.data() as Map<String, dynamic>)['fechaEvento'] as Timestamp;
      final Timestamp fechaB = (b.data() as Map<String, dynamic>)['fechaEvento'] as Timestamp;
      return fechaA.compareTo(fechaB);
    });

    final topEventos = eventosFuturos.take(5).toList();

    return _buildDashboardBlock(
      title: 'Próximos Eventos',
      icon: Icons.event_available_rounded,
      child: topEventos.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No hay eventos programados próximamente.',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topEventos.length,
              itemBuilder: (context, index) {
                final data = topEventos[index].data() as Map<String, dynamic>;
                final DateTime fecha = (data['fechaEvento'] as Timestamp).toDate();
                final String nombreEvento = data['nombreEvento'] ?? 'Logística de Evento';
                final String emailCliente = data['emailCliente'] ?? 'Sin correo';
                
                final String diaMes = "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}";
                final String horaStr = "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

                final int diasFaltantes = fecha.difference(DateTime.now()).inDays;
                Color dotColor = primaryColor;
                if (diasFaltantes < 0) {
                  dotColor = Colors.redAccent; 
                } else if (diasFaltantes <= 3) {
                  dotColor = Colors.orange; 
                } else {
                  dotColor = Colors.teal; 
                }

                return _buildNuevoAgendaItem(
                  title: nombreEvento,
                  location: emailCliente,
                  date: diaMes,
                  time: horaStr,
                  dotColor: dotColor,
                );
              },
            ),
    );
  }

  Widget _buildNuevoAgendaItem({required String title, required String location, required String date, required String time, required Color dotColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(location, style: const TextStyle(fontSize: 13, color: Colors.grey), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: dotColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(date, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: dotColor)),
                Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: dotColor.withAlpha(200))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolicitudesTab(List<QueryDocumentSnapshot> docs, double paddingValue) {
    List<QueryDocumentSnapshot> solicitudesOrdenadas = List.from(docs);

    solicitudesOrdenadas.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;

      final Timestamp? fechaA = dataA['fechaEvento'] as Timestamp?;
      final Timestamp? fechaB = dataB['fechaEvento'] as Timestamp?;

      if (fechaA == null && fechaB == null) return 0;
      if (fechaA == null) return 1;
      if (fechaB == null) return -1;
      return fechaA.compareTo(fechaB);
    });

    return Padding(
      padding: EdgeInsets.all(paddingValue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildHeader('Bandeja de Solicitudes', 'Listado maestro de asignaciones de formularios.')),
              TextButton.icon(
                onPressed: () => _mostrarHistorialCompletadas(context),
                icon: const Icon(Icons.history_rounded, color: primaryColor),
                label: const Text('Ver Historial', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  backgroundColor: primaryColor.withAlpha(20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: solicitudesOrdenadas.isEmpty
                ? const Center(child: Text('No existen solicitudes registradas.', style: TextStyle(fontSize: 16)))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 820) {
                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 450, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.3,
                          ),
                          itemCount: solicitudesOrdenadas.length,
                          itemBuilder: (context, index) {
                            return _buildSolicitudCard(solicitudesOrdenadas[index], context);
                          },
                        );
                      }
                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        itemCount: solicitudesOrdenadas.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildSolicitudCard(solicitudesOrdenadas[index], context);
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

    eventosConFecha.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;
      final Timestamp fechaA = dataA['fechaEvento'] as Timestamp;
      final Timestamp fechaB = dataB['fechaEvento'] as Timestamp;
      return fechaA.compareTo(fechaB);
    });

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
                      final doc = eventosConFecha[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final docId = doc.id;
                      final DateTime fecha = (data['fechaEvento'] as Timestamp).toDate();
                      final String folio = data['folio'] ?? docId.substring(0, 5).toUpperCase();
                      final String emailCliente = data['emailCliente'] ?? 'Sin correo';
                      final String tipoCatering = data['nombreEvento'] ?? 'Logística de Evento';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Provider.of<SolicitudesProvider>(context, listen: false).seleccionarSolicitud(doc);
                            Navigator.pushNamed(context, AppRoutes.solicitudForm);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
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
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey.shade100, width: 1.5), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10), 
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.7), primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Text(trend, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDashboardBlock({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: primaryColor, size: 22), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor))]),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  void _mostrarDialogoPerfil(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String emailUsuario = user?.email ?? 'correo@productora.cl';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.badge_rounded, color: primaryColor),
            SizedBox(width: 10),
            Text('Información del Usuario', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 35,
                backgroundColor: primaryColor.withAlpha(30),
                child: const Icon(Icons.person, size: 40, color: primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            Text('Rol en la Empresa:', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const Text('Operador / Trabajador Autorizado', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Correo Electrónico:', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            Text(emailUsuario, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoCambiarPassword(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Actualizar Contraseña', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Por seguridad, ingresa una clave nueva que tenga al menos 6 caracteres.'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline, color: primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 2)),
                      ),
                      validator: (val) => (val == null || val.trim().length < 6) ? 'Mínimo 6 caracteres.' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        await Provider.of<AuthProvider>(context, listen: false).actualizarContrasenaTrabajador(passwordController.text.trim());
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña modificada con éxito'), backgroundColor: Colors.green));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
                      }
                    }
                  },
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

 void _mostrarConfirmacionLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Cerrar Sesión?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Tendrás que volver a ingresar tus credenciales para acceder al panel.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              Navigator.pop(dialogContext);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
              await Future.delayed(const Duration(milliseconds: 500));
              await FirebaseAuth.instance.signOut();
              
              if (!context.mounted) return;
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarHistorialCompletadas(BuildContext context) {
    final completadas = Provider.of<SolicitudesProvider>(context, listen: false).solicitudesCompletadas;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.inventory_2_rounded, color: primaryColor),
            SizedBox(width: 10),
            Text('Historial de Eventos', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: completadas.isEmpty
              ? const Center(child: Text('Aún no hay eventos completados.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: completadas.length,
                  itemBuilder: (context, index) {
                    final data = completadas[index].data() as Map<String, dynamic>;
                    final String folio = data['folio'] ?? 'S/N';
                    final String email = data['emailCliente'] ?? 'Sin correo';
                    final String tipo = data['nombreEvento'] ?? 'Evento';
                    
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white, size: 20)),
                      title: Text(tipo, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Folio: #$folio | $email'),
                      trailing: const Text('Completado', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}