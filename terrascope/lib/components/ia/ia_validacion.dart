import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/services/ia_service.dart';

/// 🧠 Componente base de identificación por IA
/// Reutilizable en distintas pantallas
class IAIdentificacion extends StatefulWidget {
  const IAIdentificacion({super.key});

  @override
  State<IAIdentificacion> createState() => _IAIdentificacionState();
}

class _IAIdentificacionState extends State<IAIdentificacion> {
  File? _imagenSeleccionada;
  bool _cargando = false;
  Map<String, dynamic>? _resultadoIA;

  /// 📸 Selecciona una imagen desde la galería
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
        _resultadoIA = null; // Limpiar resultado previo
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionó ninguna imagen')),
      );
    }
  }

  /// 🤖 Envía la imagen al servicio IA para identificar la especie
  Future<void> _identificarEspecie() async {
    if (_imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero selecciona una imagen')),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final bytes = await _imagenSeleccionada!.readAsBytes();
      final imagenBase64 = base64Encode(bytes);

      // Llamada al servicio de IA (debes tener IAService configurado)
      final resultado = await IAService.identificarEspecie(imagenBase64);

      setState(() {
        _resultadoIA = resultado;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al identificar: $e')),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Identificación de Seres Vivos"),
        backgroundColor: const Color(0xFF5C6445),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📷 Vista previa de la imagen seleccionada
            GestureDetector(
              onTap: _seleccionarImagen,
              child: _imagenSeleccionada != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _imagenSeleccionada!,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 80, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Toca para seleccionar una imagen',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // 🖼️ Botón seleccionar imagen
            ElevatedButton.icon(
              onPressed: _seleccionarImagen,
              icon: const Icon(Icons.photo_library),
              label: const Text("Seleccionar imagen"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C6445),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔍 Botón identificar
            ElevatedButton.icon(
              onPressed: _cargando ? null : _identificarEspecie,
              icon: _cargando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(_cargando ? "Analizando..." : "Identificar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F1D33),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🧾 Resultado IA
            if (_resultadoIA != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🔍 Resultado de Identificación",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text("🌿 Nombre común: ${_resultadoIA!['nombre_comun']}"),
                    Text("🧬 Nombre científico: ${_resultadoIA!['nombre_cientifico']}"),
                    Text("📊 Nivel de confianza: ${_resultadoIA!['nivel_confianza']}"),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
