import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/location_service.dart';
import '../../services/camera_service.dart';
import '../../services/fauna_flora_service.dart';
import '../models/ubicacion.dart';
import '../models/habitat.dart';
import '../models/fauna_flora_data.dart';

class RegistroAvistamientoScreen extends StatefulWidget {
  @override
  _RegistroAvistamientoScreenState createState() =>
      _RegistroAvistamientoScreenState();
}

class _RegistroAvistamientoScreenState extends State<RegistroAvistamientoScreen> {
  // Servicios
  final LocationService _locationService = LocationService();
  final CameraService _cameraService = CameraService();
  final FaunaFloraService _faunaFloraService = FaunaFloraService(
    baseUrl: 'https://tu-api.com/api', // Cambia por tu URL
  );

  // Estado
  File? _imageFile;
  Ubicacion? _ubicacion;
  String? _base64Image;
  bool _isLoading = false;

  // Controladores de formulario
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreComunController = TextEditingController();
  final TextEditingController _nombreCientificoController = TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _comportamientoController = TextEditingController();
  final TextEditingController _estadoExtincionController = TextEditingController();
  final TextEditingController _estadoEspecimenController = TextEditingController();
  final TextEditingController _nombreHabitadController = TextEditingController();
  final TextEditingController _descripcionHabitatController = TextEditingController();

  // Listas para dropdowns
  final List<String> _especies = [
    'Mamífero',
    'Ave',
    'Reptil',
    'Anfibio',
    'Pez',
    'Insecto',
    'Planta',
    'Otro'
  ];

  final List<String> _estadosExtincion = [
    'No evaluado',
    'Preocupación menor',
    'Casi amenazado',
    'Vulnerable',
    'En peligro',
    'En peligro crítico',
    'Extinto en estado silvestre',
    'Extinto'
  ];

  final List<String> _estadosEspecimen = [
    'Salvaje',
    'Cautiverio',
    'Semi-cautiverio',
    'Desconocido'
  ];

  String? _especieSeleccionada;
  String? _estadoExtincionSeleccionado;
  String? _estadoEspecimenSeleccionado;

  @override
  void initState() {
    super.initState();
    _estadoExtincionSeleccionado = 'No evaluado';
    _estadoEspecimenSeleccionado = 'Salvaje';
  }

  Future<void> _capturePhotoAndLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tomar foto
      File? imageFile = await _cameraService.takePhoto();
      if (imageFile == null) {
        _showMessage('Captura de foto cancelada', isError: false);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtener ubicación
      Ubicacion? ubicacion = await _locationService.getCurrentLocation();
      if (ubicacion == null) {
        _showMessage('No se pudo obtener la ubicación', isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Convertir imagen a Base64
      String base64Image = await _cameraService.convertImageToBase64(imageFile);

      setState(() {
        _imageFile = imageFile;
        _base64Image = base64Image;
        _ubicacion = ubicacion;
        _isLoading = false;
      });

      _showMessage(
        'Foto capturada en: ${ubicacion.latitud.toStringAsFixed(6)}, ${ubicacion.longitud.toStringAsFixed(6)}',
        isError: false,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error: ${e.toString()}', isError: true);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Seleccionar imagen
      File? imageFile = await _cameraService.pickImageFromGallery();
      if (imageFile == null) {
        _showMessage('Selección cancelada', isError: false);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtener ubicación actual (aunque la foto sea de galería)
      Ubicacion? ubicacion = await _locationService.getCurrentLocation();
      if (ubicacion == null) {
        _showMessage('No se pudo obtener la ubicación', isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Convertir imagen a Base64
      String base64Image = await _cameraService.convertImageToBase64(imageFile);

      setState(() {
        _imageFile = imageFile;
        _base64Image = base64Image;
        _ubicacion = ubicacion;
        _isLoading = false;
      });

      _showMessage('Imagen seleccionada', isError: false);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error: ${e.toString()}', isError: true);
    }
  }

  Future<void> _submitData() async {
    if (_imageFile == null || _ubicacion == null) {
      _showMessage('Primero debes capturar una foto', isError: true);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _showMessage('Completa todos los campos obligatorios', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final faunaFloraData = FaunaFloraData(
        nombreComun: _nombreComunController.text,
        nombreCientifico: _nombreCientificoController.text,
        especie: _especieSeleccionada ?? _especieController.text,
        descripcion: _descripcionController.text,
        imagenBase64: _base64Image!,
        ubicacion: _ubicacion!,
        comportamiento: _comportamientoController.text,
        estadoExtincion: _estadoExtincionSeleccionado!,
        estadoEspecimen: _estadoEspecimenSeleccionado!,
        habitad: Habitat(
          nombreHabitad: _nombreHabitadController.text,
          descripcionHabitat: _descripcionHabitatController.text.isNotEmpty
              ? _descripcionHabitatController.text
              : null,
        ),
      );

      await _faunaFloraService.createFaunaFlora(faunaFloraData);

      setState(() {
        _isLoading = false;
      });

      _showMessage('¡Avistamiento registrado exitosamente!', isError: false);
      
      // Limpiar formulario
      _clearForm();
      
      // Opcional: Navegar a otra pantalla
      // Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error al registrar: ${e.toString()}', isError: true);
    }
  }

  void _clearForm() {
    setState(() {
      _imageFile = null;
      _ubicacion = null;
      _base64Image = null;
      _especieSeleccionada = null;
      _estadoExtincionSeleccionado = 'No evaluado';
      _estadoEspecimenSeleccionado = 'Salvaje';
    });
    _nombreComunController.clear();
    _nombreCientificoController.clear();
    _especieController.clear();
    _descripcionController.clear();
    _comportamientoController.clear();
    _estadoExtincionController.clear();
    _estadoEspecimenController.clear();
    _nombreHabitadController.clear();
    _descripcionHabitatController.clear();
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Avistamiento'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Procesando...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Botones para capturar foto
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _capturePhotoAndLocation,
                            icon: Icon(Icons.camera_alt),
                            label: Text('Tomar Foto'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickFromGallery,
                            icon: Icon(Icons.photo_library),
                            label: Text('Galería'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Mostrar imagen capturada
                    if (_imageFile != null) ...[
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(height: 8),
                      if (_ubicacion != null)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lat: ${_ubicacion!.latitud.toStringAsFixed(6)}, Lng: ${_ubicacion!.longitud.toStringAsFixed(6)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 24),
                    ],

                    // Formulario
                    Text(
                      'Información del Especimen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      controller: _nombreComunController,
                      decoration: InputDecoration(
                        labelText: 'Nombre Común *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),

                    TextFormField(
                      controller: _nombreCientificoController,
                      decoration: InputDecoration(
                        labelText: 'Nombre Científico *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.science),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _especieSeleccionada,
                      decoration: InputDecoration(
                        labelText: 'Especie *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _especies.map((especie) {
                        return DropdownMenuItem(
                          value: especie,
                          child: Text(especie),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _especieSeleccionada = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecciona una especie';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),

                    TextFormField(
                      controller: _descripcionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Describe las características del especimen',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),

                    TextFormField(
                      controller: _comportamientoController,
                      decoration: InputDecoration(
                        labelText: 'Comportamiento *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.psychology),
                        hintText: 'Ej: Nocturno, cazador solitario',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _estadoExtincionSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Estado de Extinción *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning),
                      ),
                      items: _estadosExtincion.map((estado) {
                        return DropdownMenuItem(
                          value: estado,
                          child: Text(estado),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _estadoExtincionSeleccionado = value;
                        });
                      },
                    ),
                    SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _estadoEspecimenSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Estado del Especimen *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info),
                      ),
                      items: _estadosEspecimen.map((estado) {
                        return DropdownMenuItem(
                          value: estado,
                          child: Text(estado),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _estadoEspecimenSeleccionado = value;
                        });
                      },
                    ),
                    SizedBox(height: 24),

                    Text(
                      'Información del Hábitat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      controller: _nombreHabitadController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Hábitat *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.terrain),
                        hintText: 'Ej: Selva tropical, Bosque templado',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),

                    TextFormField(
                      controller: _descripcionHabitatController,
                      decoration: InputDecoration(
                        labelText: 'Descripción del Hábitat (Opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.landscape),
                        hintText: 'Describe el entorno donde se encontró',
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 32),

                    // Botón de envío
                    ElevatedButton(
                      onPressed: _submitData,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Registrar Avistamiento',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Botón para limpiar
                    OutlinedButton(
                      onPressed: _clearForm,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Limpiar Formulario',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nombreComunController.dispose();
    _nombreCientificoController.dispose();
    _especieController.dispose();
    _descripcionController.dispose();
    _comportamientoController.dispose();
    _estadoExtincionController.dispose();
    _estadoEspecimenController.dispose();
    _nombreHabitadController.dispose();
    _descripcionHabitatController.dispose();
    super.dispose();
  }
}