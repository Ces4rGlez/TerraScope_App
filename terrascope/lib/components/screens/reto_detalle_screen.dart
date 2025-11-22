import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reto_model.dart';
import '../../providers/retos_observer_provider.dart';
import '../../services/session_service.dart';
import '../../services/retos_service.dart';

class RetoDetalleScreen extends StatefulWidget {
  final Reto reto;

  const RetoDetalleScreen({super.key, required this.reto});

  @override
  State<RetoDetalleScreen> createState() => _RetoDetalleScreenState();
}

class _RetoDetalleScreenState extends State<RetoDetalleScreen>
    with WidgetsBindingObserver {
  final SessionService _sessionService = SessionService();
  final RetosService _retosService = RetosService();
  String? _usuarioId;
  bool _isLoading = false;
  Map<String, ProgresoReto>? _progreso;
  Map<String, dynamic>? _tablaPosiciones;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarDatos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cargarProgreso();
    }
  }

  Future<void> _cargarDatos() async {
    final userData = await _sessionService.getUserData();
    if (mounted) {
      setState(() {
        _usuarioId = userData?['_id'];
      });
    }

    if (_usuarioId != null) {
      await _cargarProgreso();
    }
    await _cargarTablaPosiciones();
  }

  Future<void> _cargarProgreso() async {
    final provider = Provider.of<RetosObserverProvider>(context, listen: false);
    final progreso = await provider.getProgresoReto(widget.reto.id);
    if (mounted) {
      setState(() {
        _progreso = progreso;
      });
    }
  }

  Future<void> _cargarTablaPosiciones() async {
    final tabla = await _retosService.getTablaPosiciones(widget.reto.id);
    if (mounted) {
      setState(() {
        _tablaPosiciones = tabla;
      });
    }
  }

  Future<void> _inscribirse() async {
    setState(() => _isLoading = true);

    final provider = Provider.of<RetosObserverProvider>(context, listen: false);
    final success = await provider.inscribirseReto(widget.reto.id);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '¡Inscripción exitosa!' : 'Error al inscribirse',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        await _cargarDatos();
      }
    }
  }

  Future<void> _desinscribirse() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Deseas desinscribirte de este desafío?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Desinscribirse'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<RetosObserverProvider>(context, listen: false);
    final success = await provider.desinscribirseReto(widget.reto.id);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Te has desinscrito del desafío'
                : 'Error al desinscribirse',
          ),
          backgroundColor: success ? Colors.orange : Colors.red,
        ),
      );

      if (success) {
        await _cargarDatos();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6445),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE0E0E0)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalle del Desafío',
          style: TextStyle(color: Color(0xFFE0E0E0)),
        ),
      ),
      body: Consumer<RetosObserverProvider>(
        builder: (context, provider, child) {
          final estaInscrito = provider.estaInscrito(
            widget.reto.id,
            _usuarioId,
          );
          final haCompletado = provider.haCompletado(
            widget.reto.id,
            _usuarioId,
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(haCompletado, estaInscrito),
                _buildInfoSection(),
                if (estaInscrito && !haCompletado && _progreso != null)
                  _buildProgresoSection(),
                _buildCondicionesSection(),
                if (_tablaPosiciones != null) _buildTablaPosicionesSection(),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<RetosObserverProvider>(
        builder: (context, provider, child) {
          final estaInscrito = provider.estaInscrito(
            widget.reto.id,
            _usuarioId,
          );
          final haCompletado = provider.haCompletado(
            widget.reto.id,
            _usuarioId,
          );

          if (haCompletado) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (estaInscrito ? _desinscribirse : _inscribirse),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: estaInscrito
                        ? Colors.red
                        : const Color(0xFF5C6445),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          estaInscrito ? 'Desinscribirse' : 'Aceptar Desafío',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool haCompletado, bool estaInscrito) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF5C6445), const Color(0xFF4A5237)],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              haCompletado
                  ? Icons.check_circle
                  : (estaInscrito ? Icons.trending_up : Icons.emoji_events),
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.reto.nombreReto,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.reto.descripcionReto,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          if (haCompletado) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '¡Desafío Completado!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INFORMACIÓN',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C6445),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.reto.fechaInicio != null)
            _buildInfoRow(
              Icons.calendar_today,
              'Inicio',
              _formatearFechaCompleta(widget.reto.fechaInicio!),
            ),
          if (widget.reto.fechaFinal != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.event,
              'Finaliza',
              _formatearFechaCompleta(widget.reto.fechaFinal!),
            ),
          ],
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.people,
            'Participantes',
            '${widget.reto.usuariosInscritos.length} inscritos',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.emoji_events,
            'Completados',
            '${widget.reto.usuariosFinalizados.length} usuarios',
          ),
          if (widget.reto.esTemporal) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.access_time, 'Tipo', 'Desafío Temporal'),
          ],
        ],
      ),
    );
  }

  Widget _buildProgresoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: Color(0xFF5C6445)),
              SizedBox(width: 8),
              Text(
                'TU PROGRESO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C6445),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._progreso!.entries.map((entry) {
            final key = entry.key;
            final progreso = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        key.split('.').last,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${progreso.actual} / ${progreso.requerido}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5C6445),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progreso.porcentaje / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF5C6445),
                      ),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progreso.porcentaje.toStringAsFixed(0)}% completado',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCondicionesSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REQUISITOS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C6445),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.reto.condiciones.entries.map((entry) {
            final parts = entry.key.split('.');
            final categoria = parts[0];
            final especie = parts[1];
            final cantidad = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C6445).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForCategoria(categoria, especie),
                      color: const Color(0xFF5C6445),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          especie,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Registra $cantidad avistamientos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C6445),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$cantidad',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTablaPosicionesSection() {
    final top3 = _tablaPosiciones!['top3'] as List<dynamic>;

    if (top3.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'TOP 3 - PRIMEROS EN COMPLETAR',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C6445),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...top3.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final posicion = item['posicion'] ?? (index + 1);
            final usuario = item['usuario'];
            final fecha = DateTime.parse(item['fecha_completado']);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGradientForPosition(posicion),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$posicion',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getGradientForPosition(posicion)[0],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario['nombre_usuario'] ?? 'Usuario',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Completado: ${_formatearFechaCompleta(fecha)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _getIconForPosition(posicion),
                    color: Colors.white,
                    size: 32,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF5C6445)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconForCategoria(String categoria, String especie) {
    if (categoria == 'fauna') {
      switch (especie.toLowerCase()) {
        case 'mamífero':
        case 'mamifero':
          return Icons.pets;
        case 'ave':
          return Icons.flutter_dash;
        case 'reptil':
          return Icons.workspaces_outline;
        case 'anfibio':
          return Icons.water;
        case 'pez':
          return Icons.phishing;
        case 'insecto':
          return Icons.bug_report;
        default:
          return Icons.category;
      }
    } else {
      return Icons.local_florist;
    }
  }

  List<Color> _getGradientForPosition(int posicion) {
    switch (posicion) {
      case 1:
        return [const Color(0xFFFFD700), const Color(0xFFFFB300)]; // Oro
      case 2:
        return [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)]; // Plata
      case 3:
        return [const Color(0xFFCD7F32), const Color(0xFF8B5A2B)]; // Bronce
      default:
        return [const Color(0xFF5C6445), const Color(0xFF4A5237)];
    }
  }

  IconData _getIconForPosition(int posicion) {
    switch (posicion) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      default:
        return Icons.emoji_events;
    }
  }

  String _formatearFechaCompleta(DateTime fecha) {
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}
