import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/retos_observer_provider.dart';
import '../../services/session_service.dart';
import '../models/reto_model.dart';
import 'reto_detalle_screen.dart';

class RetosActivosScreen extends StatefulWidget {
  const RetosActivosScreen({super.key});

  @override
  State<RetosActivosScreen> createState() => _RetosActivosScreenState();
}

class _RetosActivosScreenState extends State<RetosActivosScreen> {
  final SessionService _sessionService = SessionService();
  String? _usuarioId;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final userData = await _sessionService.getUserData();
    if (mounted) {
      setState(() {
        _usuarioId = userData?['_id'];
      });
    }

    final provider = Provider.of<RetosObserverProvider>(context, listen: false);
    await provider.cargarRetosActivos();
    await provider.cargarLogrosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5C6445),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6445),
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, color: Color(0xFFE0E0E0), size: 28),
            SizedBox(width: 8),
            Text(
              'Desafíos Activos',
              style: TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.military_tech, color: Color(0xFFE0E0E0)),
            onPressed: () {
              Navigator.pushNamed(context, '/logros');
            },
            tooltip: 'Mis Logros',
          ),
        ],
      ),
      body: Consumer<RetosObserverProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE0E0E0)),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFE0E0E0),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Color(0xFFE0E0E0)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _cargarDatos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: const Color(0xFF5C6445),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.retosActivos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Color(0xFFE0E0E0),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay desafíos activos',
                    style: TextStyle(fontSize: 18, color: Color(0xFFE0E0E0)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los nuevos retos se generan cada 2 horas',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFFE0E0E0).withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _cargarDatos,
            color: const Color(0xFF5C6445),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.retosActivos.length,
              itemBuilder: (context, index) {
                final reto = provider.retosActivos[index];
                return _buildRetoCard(reto, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRetoCard(Reto reto, RetosObserverProvider provider) {
    final estaInscrito = provider.estaInscrito(reto.id, _usuarioId);
    final haCompletado = provider.haCompletado(reto.id, _usuarioId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RetoDetalleScreen(reto: reto),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C6445).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      haCompletado
                          ? Icons.check_circle
                          : (estaInscrito
                                ? Icons.trending_up
                                : Icons.emoji_events),
                      color: haCompletado
                          ? Colors.green
                          : const Color(0xFF5C6445),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reto.nombreReto,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F1D33),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reto.descripcionReto,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (reto.esTemporal && reto.fechaFinal != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFF5C6445),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Finaliza: ${_formatearFecha(reto.fechaFinal!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5C6445),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      Icons.people,
                      '${reto.usuariosInscritos.length} inscritos',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      Icons.emoji_events,
                      '${reto.usuariosFinalizados.length} completados',
                    ),
                  ),
                ],
              ),

              if (haCompletado) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 16, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        '¡Desafío Completado!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (estaInscrito) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C6445).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF5C6445)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Color(0xFF5C6445),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Inscrito',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5C6445),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF5C6445)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: Color(0xFF5C6445)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = fecha.difference(ahora);

    if (diferencia.inDays > 0) {
      return '${diferencia.inDays} días';
    } else if (diferencia.inHours > 0) {
      return '${diferencia.inHours} horas';
    } else {
      return 'Pronto';
    }
  }
}
