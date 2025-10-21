import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/camera_service.dart';
import '../../services/fauna_flora_service.dart';
import '../../services/session_service.dart';
import '../../services/habitat_service.dart';
import '../../components/models/avistamiento_model.dart';
import '../../components/models/habitat.dart';
import '../../config/api_config.dart';

class CreateAvistamientoScreen extends StatefulWidget {
  const CreateAvistamientoScreen({super.key});

  @override
  State<CreateAvistamientoScreen> createState() =>
      _CreateAvistamientoScreenState();
}

class _CreateAvistamientoScreenState extends State<CreateAvistamientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final CameraService _cameraService = CameraService();
  final FaunaFloraService _service = FaunaFloraService(
    baseUrl: ApiConfig.baseUrl,
  );
  final SessionService _sessionService = SessionService();
  final HabitatService _habitatService = HabitatService(
    baseUrl: ApiConfig.baseUrl,
  );

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
  List<Habitat> _habitats = [];
  Habitat? _selectedHabitat;

  final List<String> _comportamientosComunes = [
    'Agresivo',
    'Tranquilo',
    'Temeroso',
    'Curioso',
    'Territorial',
  ];

  @override
  void initState() {
    super.initState();
    _loadHabitats();
  }

  Future<void> _loadHabitats() async {
    try {
      final habitats = await _habitatService.getAllHabitats();
      if (mounted) {
        setState(() {
          _habitats = habitats;
          _isLoadingHabitats = false;
        });
      }
    } catch (e) {
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
    _especieController.dispose();
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
        // NO obtener ubicación automáticamente - deja que el usuario la pida
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
        // NO obtener ubicación automáticamente - deja que el usuario la pida
      }
    } catch (e) {
      _showError('Error al seleccionar imagen: $e');
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
        throw Exception(
          'Los servicios de ubicación están deshabilitados. Por favor actívalos en configuración.',
        );
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
        throw Exception(
          'Los permisos de ubicación están denegados permanentemente. Ve a configuración para habilitarlos.',
        );
      }

      // Intentar obtener última ubicación conocida (más rápido)
      Position? lastPosition = await Geolocator.getLastKnownPosition();

      if (lastPosition != null) {
        if (mounted) {
          setState(() {
            _latitudController.text = lastPosition.latitude.toStringAsFixed(6);
            _longitudController.text = lastPosition.longitude.toStringAsFixed(
              6,
            );
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
        _showError(
          'Tiempo de espera agotado. Intenta de nuevo en un lugar con mejor señal GPS.',
        );
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
        especie: _especieController.text,
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
      );

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
            Icon(Icons.camera_alt, size: 100, color: Colors.grey[400]),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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

            // Especie
            _buildTextField(
              controller: _especieController,
              label: 'Especie',
              hint: 'Ej: Mamífero',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),

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
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
}
