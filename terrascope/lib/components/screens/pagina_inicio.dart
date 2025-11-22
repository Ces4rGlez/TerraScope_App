import 'package:flutter/material.dart';
import 'package:terrascope/components/screens/profile_page.dart';
import 'dart:convert';
import '../../services/fauna_flora_service.dart';
import '../../components/models/avistamiento_model.dart';
import '../../config/api_config.dart';
import '../map/map_page.dart';
import '../map/avistamiento_detail_loader.dart';
import '../screens/registro_avistamiento_screen.dart';
import '../../services/session_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FaunaFloraService _service;
  final SessionService _sessionService = SessionService();
  List<Avistamiento> _avistamientos = [];
  List<Avistamiento> _avistamientosFiltrados = [];
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 0;
  String? _filtroTipo;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _service = FaunaFloraService(baseUrl: ApiConfig.baseUrl);
    _cargarAvistamientos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarAvistamientos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final avistamientos = await _service.getAllFaunaFlora();

      if (mounted) {
        setState(() {
          _avistamientos = avistamientos;
          _avistamientosFiltrados = avistamientos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar avistamientos: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter(String? tipo) {
    setState(() {
      _filtroTipo = tipo;
    });
    _filtrarAvistamientos();
  }

  void _filtrarAvistamientos() {
    List<Avistamiento> filtrados = _avistamientos;

    if (_filtroTipo != null) {
      filtrados = filtrados
          .where((a) => a.tipo.toLowerCase() == _filtroTipo!.toLowerCase())
          .toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtrados = filtrados
          .where(
            (a) =>
                a.nombreComun.toLowerCase().contains(query) ||
                a.nombreCientifico.toLowerCase().contains(query),
          )
          .toList();
    }

    setState(() {
      _avistamientosFiltrados = filtrados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5C6445),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6445),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'TerraScope',
              style: TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.eco, color: Color(0xFFE0E0E0), size: 28),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Color(0xFFE0E0E0)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );

              if (result == true) {
                _cargarAvistamientos();
              }
            },
          ),
           IconButton(
            icon: const Icon(Icons.camera_alt, color: Color(0xFFE0E0E0)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateAvistamientoScreen(),
                ),
              );

              if (result == true) {
                _cargarAvistamientos();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE0E0E0)),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFE0E0E0),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _cargarAvistamientos,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF939E69),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                _buildSearchAndFilters(),
                Expanded(
                  child: _avistamientosFiltrados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pets_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay avistamientos',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _cargarAvistamientos,
                          color: const Color(0xFF5C6445),
                          child: ListView.builder(
                            itemCount: _avistamientosFiltrados.length,
                            padding: const EdgeInsets.only(bottom: 16),
                            itemBuilder: (context, index) {
                              return AvistamientoCard(
                                data: _avistamientosFiltrados[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AvistamientoDetailLoader(
                                            avistamientoId:
                                                _avistamientosFiltrados[index]
                                                    .id,
                                            service: _service,
                                          ),
                                    ),
                                  );
                                },
                                service: _service,
                                sessionService: _sessionService,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFE0E0E0),
        selectedItemColor: const Color(0xFF5C6445),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapPage()),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                _currentIndex = 0;
              });
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: ''),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF5C6445),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => _filtrarAvistamientos(),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Buscar...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFilterChip('Todos', null),
              const SizedBox(width: 8),
              _buildFilterChip('Fauna', 'Fauna'),
              const SizedBox(width: 8),
              _buildFilterChip('Flora', 'Flora'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _filtroTipo == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _applyFilter(selected ? value : null);
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF939E69),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class AvistamientoCard extends StatefulWidget {
  final Avistamiento data;
  final VoidCallback onTap;
  final FaunaFloraService service;
  final SessionService sessionService;

  const AvistamientoCard({
    super.key,
    required this.data,
    required this.onTap,
    required this.service,
    required this.sessionService,
  });

  @override
  State<AvistamientoCard> createState() => _AvistamientoCardState();
}

class _AvistamientoCardState extends State<AvistamientoCard> {
  String _idUsuario = '';
  String _rolUsuario = 'Usuario';
  bool _isLoadingValidacion = false;
  Map<String, dynamic>? _estadoValidacion;
  bool _yaVoto = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioYValidacion();
  }

  /// 🔹 Carga usuario y validación en orden
  Future<void> _cargarUsuarioYValidacion() async {
    await _cargarUsuario();
    await _cargarEstadoValidacion();
  }

  /// 🔹 Cargar sesión de usuario
  Future<void> _cargarUsuario() async {
    final userData = await widget.sessionService.getUserData();

    print("🧠 [DEBUG] Datos de sesión obtenidos → $userData");

    if (mounted && userData != null) {
      setState(() {
        _idUsuario = userData['_id'] ?? '';
        _rolUsuario = userData['rol_usuario'] ?? 'Usuario';
      });

      print("👤 [DEBUG] Usuario actual → ID: $_idUsuario | Rol: $_rolUsuario");
    } else {
      print("⚠️ [DEBUG] No hay sesión activa o los datos son nulos.");
    }
  }

  /// 🔹 Cargar estado de validación
  Future<void> _cargarEstadoValidacion() async {
    if (widget.data.id.isEmpty) {
      print(
        "⚠️ [DEBUG] ID de avistamiento vacío, no se puede cargar validación.",
      );
      return;
    }

    setState(() => _isLoadingValidacion = true);
    try {
      final estado = await widget.service.getEstadoValidacion(
        widget.data.id,
        _idUsuario,
      );
      print("📋 [DEBUG] Estado de validación recibido → $estado");

      if (mounted) {
        setState(() {
          _estadoValidacion = estado;
          _yaVoto = estado?['yaVoto'] ?? false;
        });
      }
    } catch (e) {
      print('❌ Error al cargar validación: $e');
    } finally {
      if (mounted) setState(() => _isLoadingValidacion = false);
    }
  }

  /// 🔹 Votar como comunidad
  Future<void> _votar() async {
    if (_idUsuario.isEmpty) {
      print("⚠️ [DEBUG] No se puede votar: ID de usuario vacío.");
      return;
    }

    setState(() => _isLoadingValidacion = true);
    try {
      print(
        "📨 [DEBUG] Enviando voto de usuario $_idUsuario para ${widget.data.id}",
      );
      await widget.service.votarAvistamiento(widget.data.id, _idUsuario);
    } catch (e) {
      // ⚠️ Aquí capturamos el error 400 y seguimos
      if (e.toString().contains('400')) {
        print('⚠️ Usuario ya votó, actualizando estado de validación...');
      } else {
        print('❌ Error al votar: $e');
      }
    } finally {
      // 🔹 Siempre recargamos estado de validación
      await _cargarEstadoValidacion();
      if (mounted) setState(() => _isLoadingValidacion = false);
    }
  }

  /// 🔹 Validar como experto
  Future<void> _validarComoExperto() async {
    if (_idUsuario.isEmpty) return;
    setState(() => _isLoadingValidacion = true);
    try {
      print("👨‍🔬 [DEBUG] Validación experta por $_rolUsuario ($_idUsuario)");
      await widget.service.validarComoExperto(
        widget.data.id,
        _idUsuario,
        _rolUsuario,
      );
      await _cargarEstadoValidacion();
    } catch (e) {
      print('❌ Error al validar como experto: $e');
    } finally {
      if (mounted) setState(() => _isLoadingValidacion = false);
    }
  }

  IconData _getExtincionIcon(String estado) {
    final estadoLower = estado.toLowerCase();
    if (estadoLower.contains('peligro') || estadoLower.contains('crítico')) {
      return Icons.warning;
    } else if (estadoLower.contains('vulnerable') ||
        estadoLower.contains('amenazado')) {
      return Icons.error_outline;
    } else if (estadoLower.contains('preocupación') ||
        estadoLower.contains('menor')) {
      return Icons.info_outline;
    }
    return Icons.check_circle_outline;
  }

  Color _getExtincionColor(String estado) {
    final estadoLower = estado.toLowerCase();
    if (estadoLower.contains('peligro') || estadoLower.contains('crítico')) {
      return Colors.red;
    } else if (estadoLower.contains('vulnerable') ||
        estadoLower.contains('amenazado')) {
      return Colors.orange;
    } else if (estadoLower.contains('preocupación') ||
        estadoLower.contains('menor')) {
      return Colors.amber;
    }
    return Colors.green;
  }

  Widget _buildPlaceholder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.image_outlined, size: 80, color: Colors.grey[400]),
        Positioned(
          bottom: 60,
          right: 80,
          child: Icon(Icons.pets, size: 50, color: Colors.grey[300]),
        ),
        Positioned(
          top: 80,
          left: 100,
          child: Icon(Icons.nature, size: 40, color: Colors.grey[300]),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComentarioCard(comentario) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF5C6445),
                  radius: 16,
                  child: Text(
                    comentario.nombreUsuario[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFE0E0E0),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  comentario.nombreUsuario,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comentario.comentario,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final votos = _estadoValidacion?['votos_comunidad'] ?? 0;
    final requeridos = _estadoValidacion?['requeridos_comunidad'] ?? 0;
    final validado = _estadoValidacion?['validado_por_experto'] ?? false;
    final yaVoto = _estadoValidacion?['yaVoto'] ?? false;

    // 🔹 Logs para depuración
    print("🧠 Usuario: $_idUsuario | Rol: $_rolUsuario");
    print(
      "📊 Estado validación → votos: $votos, requeridos: $requeridos, validado: $validado",
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      elevation: 1,
      color: const Color(0xFFE0E0E0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header con usuario
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF5C6445),
                  radius: 20,
                  child: Text(
                    widget.data.nombreComun[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFE0E0E0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '@${widget.data.nombreUsuario}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black54),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // 🔹 Imagen del avistamiento
          GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[300],
              child: widget.data.imagen.isNotEmpty
                  ? Image.memory(
                      base64Decode(widget.data.imagen),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),

          // 🔹 Información general
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.nombreComun,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.data.nombreCientifico,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Tipo', widget.data.tipo),
                _buildInfoRow('Especie', widget.data.especie),
                _buildInfoRow(
                  'Estado de conservación',
                  widget.data.estadoExtincion,
                ),
                _buildInfoRow(
                  'Estado del especímen',
                  widget.data.estadoEspecimen,
                ),
                const SizedBox(height: 12),

                // 🔹 Sección de validación y votos
                _isLoadingValidacion
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF5C6445),
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: validado
                              ? Colors.green.withOpacity(0.08)
                              : const Color(0xFF5C6445).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: validado
                                ? Colors.green.withOpacity(0.4)
                                : const Color(0xFF5C6445).withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: validado
                            ? Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Validado por experto',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '$votos votos de la comunidad',
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : _rolUsuario.toLowerCase() != 'usuario'
                            ? ElevatedButton.icon(
                                onPressed: _validarComoExperto,
                                icon: const Icon(Icons.verified, size: 18),
                                label: const Text(
                                  'Validar como experto',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5C6445),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 1,
                                ),
                              )
                            : Column(
                                mainAxisSize:
                                    MainAxisSize.min, // 👈 CRÍTICO para scroll
                                crossAxisAlignment: CrossAxisAlignment
                                    .stretch, // 👈 Evita saltos
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: requeridos > 0
                                                ? votos / requeridos
                                                : 0,
                                            backgroundColor:
                                                Colors.grey.shade300,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(Color(0xFF5C6445)),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '$votos/$requeridos',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF5C6445),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  !_yaVoto
                                      ? ElevatedButton.icon(
                                          onPressed: _idUsuario.isEmpty
                                              ? null
                                              : _votar,
                                          icon: const Icon(
                                            Icons.how_to_vote,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            'Validar',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF5C6445,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            elevation: 1,
                                            disabledBackgroundColor:
                                                Colors.grey.shade300,
                                            disabledForegroundColor:
                                                Colors.grey.shade500,
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF5C6445,
                                            ).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFF5C6445,
                                              ).withOpacity(0.35),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF5C6445),
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Ya has votado',
                                                style: TextStyle(
                                                  color: Color(0xFF5C6445),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Se necesitan $requeridos votos',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                      ),

                const SizedBox(height: 16),

                // 🔹 Botón de detalle
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AvistamientoDetailLoader(
                            avistamientoId: widget.data.id,
                            service: widget.service,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C6445),
                      foregroundColor: const Color(0xFFE0E0E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Ver a detalle'),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Comentarios
                const Text(
                  'Comentarios:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (widget.data.comentarios != null &&
                    widget.data.comentarios.isNotEmpty)
                  ...widget.data.comentarios.map((c) => _buildComentarioCard(c))
                else
                  const Text('No hay comentarios'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
