import 'package:flutter/material.dart';

import '../../../core/theme/sprint1_colors.dart';

/// Landing orientada a requisitos sprint 1 (navegación, catálogo, formulario, FAQ, pie).
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _keyHero = GlobalKey();
  final _keyCatalog = GlobalKey();
  final _keyForm = GlobalKey();
  final _keyPrecio = GlobalKey();
  final _keyValor = GlobalKey();
  final _keyGaleria = GlobalKey();
  final _keyFaq = GlobalKey();
  final _keyContacto = GlobalKey();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _guestsCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String _eventType = 'Evento Corporativo';
  String _catalogFilter = 'Todos';
  bool _attemptedSubmit = false;

  static const _eventTypes = [
    'Evento Corporativo',
    'Matrimonio',
    'Cumpleanos',
    'Empresa sit-down',
  ];

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  int? get _guestsParsed {
    final raw = _guestsCtrl.text.trim();
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  int _estimatedTotal() {
    final g = _guestsParsed ?? 0;
    if (g <= 0) return 0;
    switch (_eventType) {
      case 'Evento Corporativo':
        return g * 14500;
      case 'Matrimonio':
        return g * 18000;
      case 'Cumpleanos':
        return g * 12000;
      case 'Empresa sit-down':
        return g * 16000;
      default:
        return g * 14500;
    }
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Ingresa tu nombre completo';
    }
    return null;
  }

  String? _validateEmail(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) {
      return 'El correo ingresado no es valido';
    }
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(s);
    if (!ok) return 'El correo ingresado no es valido';
    return null;
  }

  String? _validatePhone(String? v) {
    final digits = RegExp(r'^\d{9}$');
    if (v == null || !digits.hasMatch(v.trim())) {
      return 'Ingresa un telefono de 9 digitos';
    }
    return null;
  }

  void _submit() {
    setState(() => _attemptedSubmit = true);
    if (_formKey.currentState?.validate() ?? false) {
      _showConfirmation();
    }
  }

  Future<void> _showConfirmation() async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (ctx, a1, a2) {
        return Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.celebration, size: 56, color: Theme.of(ctx).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('Solicitud enviada', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Te contactaremos con la cotización en menos de 5 minutos.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(curved), child: child),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _guestsCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guests = _guestsParsed;
    final total = _estimatedTotal();
    final showEstimate = guests != null && guests > 0;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Semantics(
              header: true,
              child: const Text('Sabores Interculturales'),
            ),
            actions: [
              IconButton(
                tooltip: 'Inicio',
                icon: const Icon(Icons.home_outlined),
                onPressed: () => _scrollTo(_keyHero),
              ),
              IconButton(
                tooltip: 'Catálogo',
                icon: const Icon(Icons.restaurant_menu),
                onPressed: () => _scrollTo(_keyCatalog),
              ),
              IconButton(
                tooltip: 'Cotización',
                icon: const Icon(Icons.request_quote_outlined),
                onPressed: () => _scrollTo(_keyForm),
              ),
              IconButton(
                tooltip: 'FAQ',
                icon: const Icon(Icons.help_outline),
                onPressed: () => _scrollTo(_keyFaq),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _hero(theme),
                  const SizedBox(height: 28),
                  _sectionCatalog(theme),
                  const SizedBox(height: 28),
                  _sectionForm(theme),
                  const SizedBox(height: 28),
                  _sectionPrecio(theme, showEstimate, guests, total),
                  const SizedBox(height: 28),
                  _sectionValor(theme),
                  const SizedBox(height: 28),
                  _sectionGaleria(theme),
                  const SizedBox(height: 28),
                  _sectionFaq(theme),
                  const SizedBox(height: 28),
                  _sectionContacto(theme),
                  const SizedBox(height: 28),
                  _footer(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(ThemeData theme) {
    return KeyedSubtree(
      key: _keyHero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Sprint1Colors.tealPop, Sprint1Colors.olive],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sprint 1 UX/UI en avance',
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.95)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Experiencias gastronómicas con mirada intercultural',
                    style: theme.textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 28),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Sprint1Colors.vibrantAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _scrollTo(_keyForm),
                    icon: const Icon(Icons.edit_calendar_outlined),
                    label: const Text('Iniciar cotización'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCatalog(ThemeData theme) {
    return KeyedSubtree(
      key: _keyCatalog,
      child: _sectionCard(
        theme,
        title: 'Catalogo visual de servicios',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por palabra clave',
                labelText: 'Buscador',
              ),
            ),
            const SizedBox(height: 12),
            Text('Filtrar por tipo de evento', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Todos',
                ..._eventTypes,
              ].map((t) {
                final selected = _catalogFilter == t;
                return FilterChip(
                  label: Text(t),
                  selected: selected,
                  onSelected: (_) => setState(() => _catalogFilter = t),
                  avatar: Icon(
                    selected ? Icons.check_circle : Icons.event_outlined,
                    size: 18,
                    color: selected ? theme.colorScheme.onSecondaryContainer : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, c) {
                final cross = c.maxWidth > 720 ? 3 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cross,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  children: _catalogItems(),
                );
              },
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => _scrollTo(_keyForm),
              icon: const Icon(Icons.request_quote_outlined),
              label: const Text('Iniciar cotización'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _catalogItems() {
    final q = _searchCtrl.text.trim().toLowerCase();
    final items = [
      ('Banquetería full service', 'Evento Corporativo', Icons.set_meal_outlined),
      ('Coffee break premium', 'Empresa sit-down', Icons.local_cafe_outlined),
      ('Matrimonio campo', 'Matrimonio', Icons.favorite_outline),
      ('Cumpleaños temático', 'Cumpleanos', Icons.cake_outlined),
    ];
    var list = items.where((e) {
      if (_catalogFilter != 'Todos' && e.$2 != _catalogFilter) return false;
      if (q.isEmpty) return true;
      return e.$1.toLowerCase().contains(q) || e.$2.toLowerCase().contains(q);
    }).toList();
    if (list.isEmpty) list = items;
    return list
        .map(
          (e) => Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Sprint1Colors.cream,
                    alignment: Alignment.center,
                    child: Icon(e.$3, size: 48, color: Sprint1Colors.terracottaDeep),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(e.$2, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _sectionForm(ThemeData theme) {
    return KeyedSubtree(
      key: _keyForm,
      child: _sectionCard(
        theme,
        title: 'Formulario de cotizacion',
        child: Form(
          key: _formKey,
          autovalidateMode: _attemptedSubmit ? AutovalidateMode.always : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nombre y apellido',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 9,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (9 dígitos)',
                  prefixIcon: Icon(Icons.phone_android_outlined),
                  counterText: '',
                ),
                validator: _validatePhone,
              ),
              const SizedBox(height: 12),
              FormField<DateTime>(
                autovalidateMode: _attemptedSubmit ? AutovalidateMode.always : AutovalidateMode.disabled,
                validator: (d) {
                  if (d == null) return 'Por favor selecciona la fecha de tu evento';
                  return null;
                },
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_month_outlined),
                        title: const Text('Fecha del evento'),
                        subtitle: Text(
                          state.value == null
                              ? 'Solo fechas futuras'
                              : MaterialLocalizations.of(context).formatMediumDate(state.value!),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: state.value ?? now.add(const Duration(days: 1)),
                            firstDate: now.add(const Duration(days: 1)),
                            lastDate: now.add(const Duration(days: 365 * 3)),
                            helpText: 'Selecciona la fecha de tu evento',
                          );
                          if (picked != null) state.didChange(picked);
                        },
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Sprint1Colors.errorRed, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  state.errorText ?? '',
                                  style: const TextStyle(color: Sprint1Colors.errorRed, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tipo de evento',
                  prefixIcon: Icon(Icons.event_note_outlined),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _eventType,
                    items: _eventTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _eventType = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _guestsCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Numero de invitados',
                  prefixIcon: Icon(Icons.groups_2_outlined),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Enviar solicitud'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () => _scrollTo(_keyForm),
                icon: const Icon(Icons.request_quote_outlined),
                label: const Text('Iniciar cotización'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionPrecio(ThemeData theme, bool showEstimate, int? guests, int total) {
    return KeyedSubtree(
      key: _keyPrecio,
      child: _sectionCard(
        theme,
        title: 'Precio estimado',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showEstimate) ...[
              Text(
                '$guests invitados - $_eventType',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _priceRow(theme, 'Servicio base y logística', total * 45 ~/ 100),
              _priceRow(theme, 'Menú por persona', total * 40 ~/ 100),
              _priceRow(theme, 'Bebestibles y postres', total * 15 ~/ 100),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total referencial', style: theme.textTheme.titleMedium),
                  Text(
                    '\$${total.toString()}',
                    style: theme.textTheme.titleLarge?.copyWith(color: Sprint1Colors.tealPop),
                  ),
                ],
              ),
            ] else
              Text(
                'Completa el número de invitados en el formulario para ver un desglose orientativo.',
                style: theme.textTheme.bodyLarge,
              ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => _scrollTo(_keyForm),
              icon: const Icon(Icons.request_quote_outlined),
              label: const Text('Iniciar cotización'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(ThemeData theme, String label, int amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text('\$${amount.toString()}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sectionValor(ThemeData theme) {
    return KeyedSubtree(
      key: _keyValor,
      child: _sectionCard(
        theme,
        title: 'Propuesta de valor intercultural',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Combinamos técnicas locales y recetas de otras culturas para que tu evento sea memorable, inclusivo y con identidad chilena.',
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => _scrollTo(_keyForm),
              icon: const Icon(Icons.public_outlined),
              label: const Text('Iniciar cotización'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionGaleria(ThemeData theme) {
    return KeyedSubtree(
      key: _keyGaleria,
      child: _sectionCard(
        theme,
        title: 'Galería de eventos',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, i) => Semantics(
                  label: 'Fotografía de evento ${i + 1}',
                  child: Container(
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: [Sprint1Colors.olive, Sprint1Colors.terracotta, Sprint1Colors.tealPop, Sprint1Colors.vibrantAccent][i].withValues(alpha: 0.35),
                    ),
                    child: Icon(Icons.photo_outlined, size: 40, color: Colors.grey.shade800),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => _scrollTo(_keyForm),
              icon: const Icon(Icons.request_quote_outlined),
              label: const Text('Iniciar cotización'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionFaq(ThemeData theme) {
    return KeyedSubtree(
      key: _keyFaq,
      child: _sectionCard(
        theme,
        title: 'Preguntas frecuentes',
        child: Column(
          children: [
            ExpansionTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('¿Cuánto demora la cotización en PDF?'),
              children: const [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text('La enviamos al correo indicado en un máximo de 5 minutos hábiles.'),
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('¿Cómo protegen mis datos?'),
              children: const [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text('Validación en servidor, trazabilidad y buenas prácticas de seguridad (TLS 1.3 en producción).'),
                ),
              ],
            ),
            FilledButton.tonalIcon(
              onPressed: () => _scrollTo(_keyForm),
              icon: const Icon(Icons.request_quote_outlined),
              label: const Text('Iniciar cotización'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionContacto(ThemeData theme) {
    return KeyedSubtree(
      key: _keyContacto,
      child: _sectionCard(
        theme,
        title: 'Contacto rápido',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Déjanos un mensaje breve; respondemos en horario hábil.'),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Escribe tu mensaje',
                prefixIcon: Icon(Icons.chat_bubble_outline),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mensaje de demostración (sin backend aún).')),
                );
              },
              icon: const Icon(Icons.send_outlined),
              label: const Text('Enviar mensaje'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer(ThemeData theme) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 12),
        Text('Síguenos', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Instagram',
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: () {},
            ),
            IconButton(
              tooltip: 'Facebook',
              icon: const Icon(Icons.public_outlined),
              onPressed: () {},
            ),
            IconButton(
              tooltip: 'WhatsApp',
              icon: const Icon(Icons.chat_outlined),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          children: [
            TextButton(onPressed: () {}, child: const Text('Política de privacidad')),
            TextButton(onPressed: () {}, child: const Text('Términos y condiciones')),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Contenido en español neutro Chile · Prototipo sprint 1',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _sectionCard(ThemeData theme, {required String title, required Widget child}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
