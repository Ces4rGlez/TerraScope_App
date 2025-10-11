import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/avistamiento_model.dart';

class AvistamientoDetailCard extends StatelessWidget {
  final Avistamiento avistamiento;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;

  const AvistamientoDetailCard({
    super.key,
    required this.avistamiento,
    required this.onClose,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildImage(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            avistamiento.nombreComun,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F1D33),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            avistamiento.nombreCientifico,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                avistamiento.especie.toLowerCase() == 'flora'
                                    ? Icons.local_florist
                                    : Icons.pets,
                                size: 16,
                                color: const Color(0xFF5C6445),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Categoría: ${avistamiento.especie}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  avistamiento.descripcion,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFF5C6445),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      avistamiento.habitad.nombreHabitad,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(avistamiento.estadoExtincion),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Estado: ${avistamiento.estadoExtincion}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C6445),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ver Más Información',
                      style: TextStyle(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    try {
      if (avistamiento.imagen.startsWith('http')) {
        return Image.network(
          avistamiento.imagen,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholderImage(),
        );
      } else if (avistamiento.imagen.isNotEmpty) {
        return Image.memory(
          base64Decode(avistamiento.imagen),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholderImage(),
        );
      } else {
        return _placeholderImage();
      }
    } catch (e) {
      return _placeholderImage();
    }
  }

  Widget _placeholderImage() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[300],
      child: Icon(
        avistamiento.especie.toLowerCase() == 'flora'
            ? Icons.local_florist
            : Icons.pets,
        size: 40,
        color: Colors.grey[600],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'en peligro':
        return Colors.red;
      case 'vulnerable':
        return Colors.orange;
      case 'preocupación menor':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
