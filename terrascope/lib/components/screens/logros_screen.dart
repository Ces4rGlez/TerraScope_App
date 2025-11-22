import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/retos_observer_provider.dart';

class LogrosScreen extends StatefulWidget {
  const LogrosScreen({super.key});

  @override
  State<LogrosScreen> createState() => _LogrosScreenState();
}

class _LogrosScreenState extends State<LogrosScreen> {
  @override
  void initState() {
    super.initState();
    _cargarLogros();
  }

  Future<void> _cargarLogros() async {
    final provider = Provider.of<RetosObserverProvider>(context, listen: false);
    await provider.cargarLogrosUsuario();
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
          'Mis Logros',
          style: TextStyle(color: Color(0xFFE0E0E0)),
        ),
      ),
      body: Consumer<RetosObserverProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5C6445)),
            );
          }

          if (provider.logrosUsuario.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.military_tech_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no tienes logros',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa desafíos para obtener logros',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEstadisticas(provider),
                const SizedBox(height: 24),
                const Text(
                  'TUS LOGROS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C6445),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                ...provider.logrosUsuario.map((logro) {
                  return _buildLogroCard(logro, provider);
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEstadisticas(RetosObserverProvider provider) {
    final totalLogros = provider.logrosUsuario.length;
    final logrosVisibles = provider.logrosUsuario
        .where((l) => l.esMostrado)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C6445), Color(0xFF4A5237)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.emoji_events, '$totalLogros', 'Logros Totales'),
          Container(width: 1, height: 60, color: Colors.white.withOpacity(0.3)),
          _buildStatItem(Icons.visibility, '$logrosVisibles', 'Visibles'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildLogroCard(dynamic logro, RetosObserverProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    logro.nombreLogro,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    logro.descripcionTitulo,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatearFecha(logro.fechaObtencion),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                logro.esMostrado ? Icons.visibility : Icons.visibility_off,
                color: logro.esMostrado ? const Color(0xFF5C6445) : Colors.grey,
              ),
              onPressed: () async {
                // Aquí necesitarías el ID del logro
                // await provider.toggleMostrarLogro(logro.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
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
