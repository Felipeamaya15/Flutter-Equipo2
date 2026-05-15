import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../solicitudes/presentation/pages/solicitud_form_page.dart';

class WorkerDashboardPage extends StatelessWidget {
  const WorkerDashboardPage({super.key});

  static const _stats = [
    _DashboardStat(
      label: 'Solicitudes activas',
      value: '18',
      trend: '+4 hoy',
      icon: Icons.assignment_outlined,
      color: AppColors.mar,
    ),
    _DashboardStat(
      label: 'Eventos de la semana',
      value: '7',
      trend: '3 en montaje',
      icon: Icons.event_available_outlined,
      color: AppColors.hoja,
    ),
    _DashboardStat(
      label: 'Cotizaciones pendientes',
      value: '5',
      trend: '2 urgentes',
      icon: Icons.request_quote_outlined,
      color: AppColors.arcilla,
    ),
    _DashboardStat(
      label: 'Satisfaccion',
      value: '94%',
      trend: 'ultimo mes',
      icon: Icons.verified_outlined,
      color: AppColors.exito,
    ),
  ];

  static const _tasks = [
    _WorkItem(
      title: 'Confirmar menu mapuche-fusion',
      subtitle: 'Matrimonio Curacavi - 120 invitados',
      status: 'Hoy 11:30',
      color: AppColors.arcilla,
    ),
    _WorkItem(
      title: 'Revisar anticipo recibido',
      subtitle: 'Coffee break TechAndes',
      status: 'Finanzas',
      color: AppColors.mar,
    ),
    _WorkItem(
      title: 'Asignar equipo de montaje',
      subtitle: 'Evento corporativo Las Condes',
      status: 'Operacion',
      color: AppColors.hoja,
    ),
  ];

  static const _agenda = [
    _WorkItem(
      title: 'Degustacion cliente',
      subtitle: 'Sala norte',
      status: '09:00',
      color: AppColors.maiz,
    ),
    _WorkItem(
      title: 'Despacho insumos',
      subtitle: 'Bodega central',
      status: '13:00',
      color: AppColors.hoja,
    ),
    _WorkItem(
      title: 'Cierre de propuesta',
      subtitle: 'Fundacion Raices',
      status: '16:30',
      color: AppColors.arcilla,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showRail = constraints.maxWidth >= 920;

        return Scaffold(
          appBar: showRail
              ? null
              : _MobileAppBar(onNewRequest: () => _openRequestForm(context)),
          body: Row(
            children: [
              if (showRail)
                _DashboardRail(onNewRequest: () => _openRequestForm(context)),
              Expanded(
                child: SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          showRail ? 32 : 20,
                          24,
                          showRail ? 32 : 20,
                          32,
                        ),
                        sliver: SliverList.list(
                          children: [
                            _Header(
                              onNewRequest: () => _openRequestForm(context),
                            ),
                            const SizedBox(height: 24),
                            _StatsGrid(stats: _stats),
                            const SizedBox(height: 24),
                            _DashboardColumns(tasks: _tasks, agenda: _agenda),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openRequestForm(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SolicitudFormPage()));
  }
}

class _MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MobileAppBar({required this.onNewRequest});

  final VoidCallback onNewRequest;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Panel trabajador'),
      actions: [
        IconButton(
          tooltip: 'Nueva solicitud',
          onPressed: onNewRequest,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _DashboardRail extends StatelessWidget {
  const _DashboardRail({required this.onNewRequest});

  final VoidCallback onNewRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 244,
      color: AppColors.superficie,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo_sobre_nosotros.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Productora Intercultural',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _RailItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              selected: true,
            ),
            _RailItem(icon: Icons.assignment_outlined, label: 'Solicitudes'),
            _RailItem(icon: Icons.calendar_month_outlined, label: 'Agenda'),
            _RailItem(icon: Icons.groups_2_outlined, label: 'Equipo'),
            const Spacer(),
            FilledButton.icon(
              onPressed: onNewRequest,
              icon: const Icon(Icons.add),
              label: const Text('Nueva solicitud'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.mar : AppColors.textoSuave;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? AppColors.mar.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(icon, color: foreground),
          title: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onNewRequest});

  final VoidCallback onNewRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 16,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Panel trabajador', style: theme.textTheme.displayLarge),
              const SizedBox(height: 8),
              Text(
                'Gestion diaria de solicitudes, eventos y tareas del equipo.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textoSuave,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined),
              label: const Text('Reporte'),
            ),
            FilledButton.icon(
              onPressed: onNewRequest,
              icon: const Icon(Icons.add),
              label: const Text('Nueva solicitud'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<_DashboardStat> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1080
            ? 4
            : constraints.maxWidth >= 680
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 168,
          ),
          itemBuilder: (context, index) => _StatCard(stat: stats[index]),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _DashboardStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _IconBadge(icon: stat.icon, color: stat.color),
                Text(stat.trend, style: theme.textTheme.bodyMedium),
              ],
            ),
            const Spacer(),
            Text(
              stat.value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: stat.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(stat.label, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _DashboardColumns extends StatelessWidget {
  const _DashboardColumns({required this.tasks, required this.agenda});

  final List<_WorkItem> tasks;
  final List<_WorkItem> agenda;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final taskPanel = _WorkPanel(
          title: 'Prioridades operativas',
          icon: Icons.task_alt_outlined,
          items: tasks,
        );
        final agendaPanel = _WorkPanel(
          title: 'Agenda de hoy',
          icon: Icons.schedule_outlined,
          items: agenda,
        );

        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: taskPanel),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: agendaPanel),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [taskPanel, const SizedBox(height: 16), agendaPanel],
              );
      },
    );
  }
}

class _WorkPanel extends StatelessWidget {
  const _WorkPanel({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<_WorkItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.mar),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WorkTile(item: item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkTile extends StatelessWidget {
  const _WorkTile({required this.item});

  final _WorkItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.fondo,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.linea),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: _StatusDot(color: item.color),
        title: Text(item.title, style: theme.textTheme.titleMedium),
        subtitle: Text(item.subtitle),
        trailing: Text(
          item.status,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.texto,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: color),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const SizedBox(width: 12, height: 12),
    );
  }
}

class _DashboardStat {
  const _DashboardStat({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;
}

class _WorkItem {
  const _WorkItem({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String status;
  final Color color;
}
