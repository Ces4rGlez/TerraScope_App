import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/fauna_flora_service.dart';
import '../../components/models/avistamiento_model.dart';
import '../../config/api_config.dart';
import '../map/map_page.dart';
import '../map/avistamiento_detail_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FaunaFloraService _service;
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
      
      print('🔍 Intentando cargar avistamientos...');
      final avistamientos = await _service.getAllFaunaFlora();
      print('✅ Avistamientos cargados: ${avistamientos.length}');
      
      // Debuggear el primer avistamiento
      if (avistamientos.isNotEmpty) {
        final first = avistamientos[0];
        print('📋 Primer avistamiento:');
        print('  - nombre_comun: ${first.nombreComun}');
        print('  - tipo: ${first.tipo}');
        print('  - nombre_usuario: ${first.nombreUsuario}');
      }
      
      if (mounted) {
        setState(() {
          _avistamientos = avistamientos;
          _avistamientosFiltrados = avistamientos;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error completo: $e');
      print('📍 Stack trace completo:');
      print(stackTrace);
      
      if (mounted) {
        setState(() {
          _error = 'Error: ${e.toString()}';
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

    // Filtrar por tipo (Fauna o Flora)
    if (_filtroTipo != null) {
      filtrados = filtrados.where((a) => 
        a.tipo.toLowerCase() == _filtroTipo!.toLowerCase()
      ).toList();
    }

    // Filtrar por búsqueda
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtrados = filtrados.where((a) =>
        a.nombreComun.toLowerCase().contains(query) ||
        a.nombreCientifico.toLowerCase().contains(query)
      ).toList();
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
            icon: const Icon(Icons.camera_alt, color: Color(0xFFE0E0E0)),
            onPressed: () async {
              // Navegar a pantalla de crear avistamiento
              
              // Si se creó un avistamiento, recargar la lista
             
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFE0E0E0)),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE0E0E0),
              ),
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
                                     
                                    },
                                    service: _service ,
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
        MaterialPageRoute(
          builder: (context) => const MapPage(),
        ),
      );
      // Vuelve al índice 0 después de navegar
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

class AvistamientoCard extends StatelessWidget {
  final Avistamiento data;
  final VoidCallback onTap;
  final FaunaFloraService service;

  const AvistamientoCard({
    super.key,
    required this.data,
    required this.onTap,
    required this.service, 
  });

  // Obtener icono según estado de extinción
  IconData _getExtincionIcon(String estado) {
    final estadoLower = estado.toLowerCase();
    if (estadoLower.contains('peligro') || estadoLower.contains('crítico')) {
      return Icons.warning;
    } else if (estadoLower.contains('vulnerable') || estadoLower.contains('amenazado')) {
      return Icons.error_outline;
    } else if (estadoLower.contains('preocupación') || estadoLower.contains('menor')) {
      return Icons.info_outline;
    }
    return Icons.check_circle_outline;
  }

  // Obtener color según estado de extinción
  Color _getExtincionColor(String estado) {
    final estadoLower = estado.toLowerCase();
    if (estadoLower.contains('peligro') || estadoLower.contains('crítico')) {
      return Colors.red;
    } else if (estadoLower.contains('vulnerable') || estadoLower.contains('amenazado')) {
      return Colors.orange;
    } else if (estadoLower.contains('preocupación') || estadoLower.contains('menor')) {
      return Colors.amber;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      elevation: 1,
      color: const Color(0xFFE0E0E0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con usuario
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF5C6445),
                  radius: 20,
                  child: Text(
                    data.nombreComun[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFE0E0E0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '@${data.nombreUsuario}',

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
          
          // Imagen del avistamiento
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[300],
              child: data.imagen.isNotEmpty
                  ? Image.memory(
                      base64Decode(data.imagen),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),
          ),
          
          // Información del avistamiento
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre común y científico
                Text(
                  data.nombreComun,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.nombreCientifico,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Especie
                Row(
                  children: [
                 Icon(
                     data.tipo.toLowerCase() == 'Flora' 
                      ? Icons.local_florist 
                      : Icons.pets,
                    size: 18,
                    color: const Color(0xFF5C6445),
                  ),
                    const SizedBox(width: 6),
                    Text(
                      data.especie,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Estado de extinción
                Row(
                  children: [
                    Icon(
                      _getExtincionIcon(data.estadoExtincion),
                      size: 18,
                      color: _getExtincionColor(data.estadoExtincion),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      data.estadoExtincion,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _getExtincionColor(data.estadoExtincion),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Estado del especimen
                Row(
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      size: 18,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Estado: ${data.estadoEspecimen}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
               // Botón ver detalle - REEMPLAZA ESTO
Align(
  alignment: Alignment.centerRight,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AvistamientoDetailLoader(
            avistamientoId: data.id,
            service: service,
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
)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.image_outlined,
          size: 80,
          color: Colors.grey[400],
        ),
        Positioned(
          bottom: 60,
          right: 80,
          child: Icon(
            Icons.pets,
            size: 50,
            color: Colors.grey[300],
          ),
        ),
        Positioned(
          top: 80,
          left: 100,
          child: Icon(
            Icons.nature,
            size: 40,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }
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
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
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
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
