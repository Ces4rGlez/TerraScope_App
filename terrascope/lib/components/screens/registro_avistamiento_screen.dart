import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:terrascope/services/ia_service.dart';
import '../../services/camera_service.dart';
import '../../services/fauna_flora_service.dart';
import '../../services/session_service.dart';
import '../../services/habitat_service.dart';
import '../../components/models/avistamiento_model.dart';
import '../../components/models/habitat.dart';
import '../../config/api_config.dart';
import '../models/validacion_model.dart';

class CreateAvistamientoScreen extends StatefulWidget {
  const CreateAvistamientoScreen({super.key});

  @override
  State<CreateAvistamientoScreen> createState() =>
      _CreateAvistamientoScreenState();
}

class _CreateAvistamientoScreenState extends State<CreateAvistamientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final CameraService _cameraService = CameraService();
  final FaunaFloraService _service =
      FaunaFloraService(baseUrl: ApiConfig.baseUrl);
  final SessionService _sessionService = SessionService();
  final HabitatService _habitatService =
      HabitatService(baseUrl: ApiConfig.baseUrl);

  // Controladores de texto
  final TextEditingController _nombreComunController = TextEditingController();
  final TextEditingController _nombreCientificoController =
      TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _latitudController = TextEditingController();
  final TextEditingController _longitudController = TextEditingController();
  final TextEditingController _comportamientoController =
      TextEditingController();
  final TextEditingController _estadoEspecimenController =
      TextEditingController();

  File? _imageFile;
  String? _imageBase64;
  bool _isLoadingLocation = false;
  bool _isSaving = false;
  bool _isLoadingHabitats = true;
  String _tipo = 'Fauna';
  String _estadoExtincion = 'Preocupación menor';
  String _especieSeleccionada = 'Mamífero';
  List<Habitat> _habitats = [];
  Habitat? _selectedHabitat;
  bool _cargando = false;
  Map<String, dynamic>? _resultadoIA;


  final List<String> _comportamientosComunes = [
    'Agresivo',
    'Tranquilo',
    'Temeroso',
    'Curioso',
    'Territorial',
  ];

  final List<String> _especiesDisponibles = [
    'Mamífero',
    'Ave',
    'Reptil',
    'Anfibio',
    'Pez',
    'Insecto',
    'Planta',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _loadHabitats();
  }

  Future<void> _loadHabitats() async {
    try {
      print('🔍 Intentando cargar hábitats...');
      final habitats = await _habitatService.getAllHabitats();
      print('✅ Hábitats cargados: ${habitats.length}');
      
      if (habitats.isNotEmpty) {
        print('📋 Primer hábitat: ${habitats[0].nombreHabitat}');
      }
      
      if (mounted) {
        setState(() {
          _habitats = habitats;
          _isLoadingHabitats = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error al cargar hábitats: $e');
      print('📍 Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _isLoadingHabitats = false;
        });
        _showError('Error al cargar hábitats: $e');
      }
    }
  }

  @override
  void dispose() {
    _nombreComunController.dispose();
    _nombreCientificoController.dispose();
    _descripcionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _comportamientoController.dispose();
    _estadoEspecimenController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
  try {
    final File? photo = await _cameraService.takePhoto();
    if (photo != null) {
      final String base64 = await _cameraService.convertImageToBase64(photo);
      if (mounted) {
        setState(() {
          _imageFile = photo;
          _imageBase64 = base64;
        });
      }

    }
  } catch (e) {
    _showError('Error al tomar foto: $e');
  }
}

Future<void> _pickImageFromGallery() async {
  try {
    final File? image = await _cameraService.pickImageFromGallery();
    if (image != null) {
      final String base64 = await _cameraService.convertImageToBase64(image);
      if (mounted) {
        setState(() {
          _imageFile = image;
          _imageBase64 = base64;
        });
      }
    }
  } catch (e) {
    _showError('Error al seleccionar imagen: $e');
  }
}

Future<void> _showSpeciesModal() async {
  if (_resultadoIA == null) return;

  final nombreComunIA = _resultadoIA!['nombre_comun'] ?? '';
  final nombreCientificoIA = _resultadoIA!['nombre_cientifico'] ?? '';
  final descripcionIA = _resultadoIA!['descripcion'] ?? '';
  final nivelConfianza = _resultadoIA!['nivel_confianza'] ?? '';

  bool isUnknown = nombreComunIA.toLowerCase() == 'desconocido' ||
                   nombreCientificoIA.toLowerCase() == 'desconocido';

  double getConfidencePercent(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'alto':
        return 1.0; // 100%
      case 'medio':
        return 0.66; // 66%
      case 'bajo':
        return 0.33; // 33%
      default:
        return 0.0;
    }
  }

  Color getColorForConfidence(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'alto':
        return Colors.green;
      case 'medio':
        return Colors.yellow[700]!;
      case 'bajo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  showDialog(
    context: context,
    builder: (context) {
      final percent = getConfidencePercent(nivelConfianza);
      final color = getColorForConfidence(nivelConfianza);

      return AlertDialog(
        title: const Text('Información del Avistamiento'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (nombreComunIA.isNotEmpty)
                Text('Nombre Común: $nombreComunIA', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (nombreCientificoIA.isNotEmpty)
                Text('Nombre Científico: $nombreCientificoIA', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (descripcionIA.isNotEmpty)
                Text('Descripción: $descripcionIA'),
              const SizedBox(height: 16),
              if (nivelConfianza.isNotEmpty) ...[
                const Text('Nivel de Confianza:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percent,
                    color: color,
                    backgroundColor: Colors.grey[300],
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nivelConfianza,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: isUnknown
                ? null // deshabilita el botón si es "Desconocido"
                : () {
                    setState(() {
                      _nombreComunController.text = nombreComunIA;
                      _nombreCientificoController.text = nombreCientificoIA;
                    });
                    Navigator.of(context).pop();
                  },
            child: const Text('Autocompletar campos'),
          ),
        ],
      );
    },
  );
}




/// 🔍 Llamada al servicio de IA
Future<void> _identificarEspecie(String imagenBase64) async {
  try {
    setState(() => _cargando = true);

    final resultado = await IAService.identificarEspecie(imagenBase64);

    if (mounted) {
      setState(() {
        _resultadoIA = resultado;
      });
      _showSpeciesModal();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Identificación completada')),
      
    );
  } catch (e) {
    _showError('Error al identificar: $e');
  } finally {
    if (mounted) setState(() => _cargando = false);
  }
}


  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Verificar si los servicios de ubicación están habilitados
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están deshabilitados. Por favor actívalos en configuración.');
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Los permisos de ubicación están denegados permanentemente. Ve a configuración para habilitarlos.');
      }

      // Intentar obtener última ubicación conocida (más rápido)
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      
      if (lastPosition != null) {
        if (mounted) {
          setState(() {
            _latitudController.text = lastPosition.latitude.toStringAsFixed(6);
            _longitudController.text = lastPosition.longitude.toStringAsFixed(6);
            _isLoadingLocation = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ubicación obtenida (última conocida)'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }

      // Si no hay última ubicación, obtener la actual con timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      if (mounted) {
        setState(() {
          _latitudController.text = position.latitude.toStringAsFixed(6);
          _longitudController.text = position.longitude.toStringAsFixed(6);
          _isLoadingLocation = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación obtenida exitosamente'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        _showError('Tiempo de espera agotado. Intenta de nuevo en un lugar con mejor señal GPS.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        _showError('Error al obtener ubicación: $e');
      }
    }
  }

 Future<void> _saveAvistamiento() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (_imageBase64 == null) {
    _showError('Por favor, toma una foto primero');
    return;
  }

  if (_latitudController.text.isEmpty || _longitudController.text.isEmpty) {
    _showError('Por favor, obtén la ubicación primero');
    return;
  }

  setState(() {
    _isSaving = true;
  });

  try {
    // Obtener el nombre del usuario de la sesión
    final nombreUsuario = await _sessionService.getUserName();
    
    if (nombreUsuario == null) {
      _showError('No hay sesión activa. Por favor inicia sesión.');
      setState(() {
        _isSaving = false;
      });
      return;
    }

    if (_selectedHabitat == null) {
      _showError('Por favor selecciona un hábitat');
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final avistamiento = Avistamiento(
      id: '',
      nombreComun: _nombreComunController.text,
      nombreCientifico: _nombreCientificoController.text,
      especie: _especieSeleccionada,
      descripcion: _descripcionController.text,
      imagen: _imageBase64!,
      ubicacion: Ubicacion(
        latitud: double.parse(_latitudController.text),
        longitud: double.parse(_longitudController.text),
      ),
      comportamiento: _comportamientoController.text,
      estadoExtincion: _estadoExtincion,
      estadoEspecimen: _estadoEspecimenController.text,
      habitat: _selectedHabitat!,
      comentarios: [],
      tipo: _tipo,
      nombreUsuario: nombreUsuario,
      // NO pasas validacion aquí, se inicializa automáticamente con valores por defecto
    );

    print('📤 Datos a enviar:');
    print('  - Nombre: ${avistamiento.nombreComun}');
    print('  - Usuario: ${avistamiento.nombreUsuario}');
    print('  - Tipo: ${avistamiento.tipo}');
    print('  - Habitat ID: ${avistamiento.habitat.idHabitat}');
    print('  - Ubicación: ${avistamiento.ubicacion.latitud}, ${avistamiento.ubicacion.longitud}');
    print('  - Validación: ${avistamiento.validacion.estado}, votos: ${avistamiento.validacion.votosComunidad}'); // 👈 Opcional: para debug
    
    final jsonData = avistamiento.toJson();
    print('📋 JSON completo:');
    print(jsonData);

    await _service.createFaunaFlora(avistamiento);

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avistamiento creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    _showError('Error al guardar: $e');
  } finally {
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
}

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6445),
        elevation: 0,
        title: const Text(
          'Nuevo Avistamiento',
          style: TextStyle(color: Color(0xFFE0E0E0)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE0E0E0)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _imageFile == null ? _buildCameraStep() : _buildFormStep(),
    );
  }

  Widget _buildCameraStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Captura la imagen del avistamiento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F1D33),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Toma una foto clara del animal o planta',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera),
                label: const Text('Tomar Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C6445),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Seleccionar de Galería'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5C6445),
                  side: const BorderSide(color: Color(0xFF5C6445)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen capturada
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(_imageFile!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _imageFile = null;
                          _imageBase64 = null;
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Botón para identificar especie
if (_imageBase64 != null)
  SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton.icon(
      onPressed: _cargando ? null : () => _identificarEspecie(_imageBase64!),
      icon: _cargando
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : const Icon(Icons.search),
      label: const Text('Identificar Especie'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5C6445),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ),
const SizedBox(height: 24),

            // Tipo (Fauna/Flora)
            const Text(
              'Tipo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Fauna', label: Text('Fauna')),
                ButtonSegment(value: 'Flora', label: Text('Flora')),
              ],
              selected: {_tipo},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _tipo = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),

            // Nombre Común
            _buildTextField(
              controller: _nombreComunController,
              label: 'Nombre Común',
              hint: 'Ej: Jaguar',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),

            // Nombre Científico
            _buildTextField(
              controller: _nombreCientificoController,
              label: 'Nombre Científico',
              hint: 'Ej: Panthera onca',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),

            // Descripción
            _buildTextField(
              controller: _descripcionController,
              label: 'Descripción',
              hint: 'Describe las características observadas',
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),

            // Especie con dropdown y iconos
            const Text(
              'Especie',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _especieSeleccionada,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _especiesDisponibles.map((especie) {
                return DropdownMenuItem<String>(
                  value: especie,
                  child: Row(
                    children: [
                      Icon(
                        _getIconForEspecie(especie),
                        color: _getColorForEspecie(especie),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        especie,
                        style: TextStyle(
                          color: _getColorForEspecie(especie),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _especieSeleccionada = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Ubicación
            const Text(
              'Ubicación',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _latitudController,
                    label: 'Latitud',
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _longitudController,
                    label: 'Longitud',
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                ),
                IconButton(
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  tooltip: 'Obtener ubicación actual',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Comportamiento con dropdown
            const Text(
              'Comportamiento',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _comportamientoController.text.isEmpty
                  ? null
                  : _comportamientoController.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              hint: const Text('Selecciona un comportamiento'),
              items: _comportamientosComunes
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _comportamientoController.text = value;
                }
              },
              validator: (value) => value == null ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),

            // Estado de Extinción
            const Text(
              'Estado de Extinción',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _estadoExtincion,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                'Preocupación menor',
                'Vulnerable',
                'En peligro',
                'En peligro crítico',
                'Extinto',
              ]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _estadoExtincion = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Estado del Especimen
            _buildTextField(
              controller: _estadoEspecimenController,
              label: 'Estado del Espécimen',
              hint: 'Ej: Saludable, Herido, etc.',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),

            // Información del Hábitat
            const Divider(height: 32),
            const Text(
              'Hábitat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF5C6445),
              ),
            ),
            const SizedBox(height: 16),

            _isLoadingHabitats
                ? const Center(child: CircularProgressIndicator())
                : _habitats.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No hay hábitats disponibles. Verifica la conexión.',
                                style: TextStyle(color: Colors.orange[900]),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadHabitats,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonFormField<Habitat>(
                    value: _selectedHabitat,
                    decoration: InputDecoration(
                      labelText: 'Selecciona un hábitat',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    hint: const Text('Selecciona un hábitat'),
                    items: _habitats.map((habitat) {
                      return DropdownMenuItem<Habitat>(
                        value: habitat,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              habitat.nombreHabitat,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              habitat.descripcionHabitat,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Habitat? value) {
                      setState(() {
                        _selectedHabitat = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Selecciona un hábitat' : null,
                  ),

            const SizedBox(height: 32),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAvistamiento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C6445),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Guardar Avistamiento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF5C6445)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos para iconos y colores de especies
  IconData _getIconForEspecie(String especie) {
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
      case 'planta':
        return Icons.local_florist;
      case 'otro':
        return Icons.category;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorForEspecie(String especie) {
    switch (especie.toLowerCase()) {
      case 'mamífero':
      case 'mamifero':
        return const Color(0xFF8D6E63); // Café
      case 'ave':
        return const Color(0xFF42A5F5); // Azul cielo
      case 'reptil':
        return const Color(0xFF66BB6A); // Verde
      case 'anfibio':
        return const Color(0xFF26C6DA); // Cyan
      case 'pez':
        return const Color(0xFF29B6F6); // Azul agua
      case 'insecto':
        return const Color(0xFFFFCA28); // Amarillo
      case 'planta':
        return const Color(0xFF4CAF50); // Verde planta
      case 'otro':
        return const Color(0xFF9E9E9E); // Gris
      default:
        return const Color(0xFF757575); // Gris oscuro
    }
  }
}