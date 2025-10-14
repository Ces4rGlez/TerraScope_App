import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/avistamiento_model.dart';
import '../../services/avistamiento_service.dart';
import 'avistamiento_detail_card.dart';
import 'avistamiento_detail_page.dart';
import '../screens/pagina_inicio.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  List<Avistamiento> _avistamientos = [];
  List<ZonaFrecuente> _zonasFrecuentes = [];
  String? _filtroEspecie;
  Avistamiento? _selectedAvistamiento;
  bool _isLoading = true;
  bool _locationError = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _requestLocationPermission();
    await _getCurrentLocation();
    await _loadAvistamientos();
    await _loadZonasFrecuentes();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de ubicación denegado')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Servicios de ubicación deshabilitados');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _locationError = false;
        });

        // Centrar el mapa en la ubicación del usuario
        _mapController.move(_currentPosition!, 13.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo obtener la ubicación: $e'),
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: _getCurrentLocation,
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadAvistamientos() async {
    try {
      final avistamientos = await AvistamientoService.getAvistamientos(
        especie: _filtroEspecie,
      );
      if (mounted) {
        setState(() {
          _avistamientos = avistamientos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar avistamientos: $e')),
        );
      }
    }
  }

  Future<void> _loadZonasFrecuentes() async {
    try {
      final zonas = await AvistamientoService.getZonasFrecuentes();
      if (mounted) {
        setState(() {
          _zonasFrecuentes = zonas;
        });
      }
    } catch (e) {
      print('Error al cargar zonas frecuentes: $e');
    }
  }

  void _applyFilter(String? especie) {
    setState(() {
      _filtroEspecie = especie;
      _isLoading = true;
    });
    _loadAvistamientos();
  }

  void _centerOnUserLocation() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 15.0);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ubicación no disponible')));
    }
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Marcador del usuario
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: _currentPosition!,
          width: 50,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.person_pin, color: Colors.white, size: 30),
          ),
        ),
      );
    }

    // Marcadores de avistamientos
    for (var avistamiento in _avistamientos) {
      markers.add(
        Marker(
          point: LatLng(
            avistamiento.ubicacion.latitud,
            avistamiento.ubicacion.longitud,
          ),
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedAvistamiento = avistamiento;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: avistamiento.especie.toLowerCase() == 'flora'
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF8D6E63),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                avistamiento.especie.toLowerCase() == 'flora'
                    ? Icons.local_florist
                    : Icons.pets,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  List<CircleMarker> _buildZonasFrecuentesCircles() {
    return _zonasFrecuentes.map((zona) {
      return CircleMarker(
        point: LatLng(zona.lat, zona.lng),
        radius: 300,
        useRadiusInMeter: true,
        color: Colors.red.withOpacity(0.2),
        borderColor: Colors.red.withOpacity(0.5),
        borderStrokeWidth: 2,
      );
    }).toList();
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
          children: [
            const Text(
              'TerraScope',
              style: TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.eco, color: Color(0xFFE0E0E0), size: 28),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Color(0xFFE0E0E0)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFE0E0E0)),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading && _avistamientos.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE0E0E0)),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    _buildSearchAndFilters(),
                    Expanded(child: _buildMap()),
                  ],
                ),
                if (_selectedAvistamiento != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AvistamientoDetailCard(
                      avistamiento: _selectedAvistamiento!,
                      onClose: () {
                        setState(() {
                          _selectedAvistamiento = null;
                        });
                      },
                      onViewDetails: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AvistamientoDetailPage(
                              avistamiento: _selectedAvistamiento!,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnUserLocation,
        backgroundColor: const Color(0xFF5C6445),
        child: const Icon(Icons.my_location, color: Color(0xFFE0E0E0)),
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
  
  if (index == 0) {
    // Navega a home
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }
  // Si es índice 1 (mapa), no hace nada porque ya estamos en MapPage
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
    final isSelected = _filtroEspecie == value;
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

  Widget _buildMap() {
    if (_currentPosition == null && !_locationError) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFE0E0E0)),
            SizedBox(height: 16),
            Text(
              'Obteniendo ubicación...',
              style: TextStyle(color: Color(0xFFE0E0E0)),
            ),
          ],
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition ?? const LatLng(0, 0),
        initialZoom: 13.0,
        onTap: (_, __) {
          setState(() {
            _selectedAvistamiento = null;
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.terrascope',
        ),
        CircleLayer(circles: _buildZonasFrecuentesCircles()),
        MarkerLayer(markers: _buildMarkers()),
      ],
    );
  }
}
