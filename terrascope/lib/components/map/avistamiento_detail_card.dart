import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../models/avistamiento_model.dart';
import '../../services/theme_service.dart';

class AvistamientoDetailCard extends StatefulWidget {
  final Avistamiento avistamiento;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;
  final VoidCallback? onShowRoute;
  final Position? userPosition;

  const AvistamientoDetailCard({
    super.key,
    required this.avistamiento,
    required this.onClose,
    required this.onViewDetails,
    this.onShowRoute,
    this.userPosition,
  });

  @override
  State<AvistamientoDetailCard> createState() => _AvistamientoDetailCardState();
}

class _AvistamientoDetailCardState extends State<AvistamientoDetailCard> {
  bool _isCalculatingDistance = false;
  double? _distanceInKm;

  @override
  void initState() {
    super.initState();
    if (widget.userPosition != null) {
      _calculateDistance();
    }
  }

  void _calculateDistance() {
    if (widget.userPosition == null) return;

    setState(() => _isCalculatingDistance = true);

    try {
      final distanceInMeters = Geolocator.distanceBetween(
        widget.userPosition!.latitude,
        widget.userPosition!.longitude,
        widget.avistamiento.ubicacion.latitud,
        widget.avistamiento.ubicacion.longitud,
      );

      setState(() {
        _distanceInKm = distanceInMeters / 1000;
        _isCalculatingDistance = false;
      });
    } catch (e) {
      setState(() => _isCalculatingDistance = false);
    }
  }

  bool get _isWithin50Km => _distanceInKm != null && _distanceInKm! <= 50;

  void _showRoute() {
    if (widget.userPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener tu ubicación'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isWithin50Km) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El avistamiento está a ${_distanceInKm!.toStringAsFixed(1)} km. Debe estar dentro de 50 km para marcar ruta.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pop(context);
    _openRouteInMap();
  }

  void _openRouteInMap() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Theme-aware colors
    final cardBackgroundColor = isDark
        ? themeProvider.darkTheme.scaffoldBackgroundColor
        : const Color(0xFFF9F9F9);
    final textColor = isDark ? Colors.white : const Color(0xFF1A2B48);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.grey[700];
    final descriptionTextColor = isDark
        ? Colors.white70
        : const Color(0xFF2E2E2E);
    final closeIconColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador superior
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[350],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen + texto principal + botón cerrar
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
                            widget.avistamiento.nombreComun,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.avistamiento.nombreCientifico,
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5C6445).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.avistamiento.tipo.toLowerCase() ==
                                          'flora'
                                      ? Icons.local_florist
                                      : Icons.pets,
                                  size: 16,
                                  color: const Color(0xFF5C6445),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.avistamiento.especie,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF5C6445),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: closeIconColor),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  'Registrado por: ${widget.avistamiento.nombreUsuario}',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.avistamiento.descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    color: descriptionTextColor,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Ubicación + distancia
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFF5C6445),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.avistamiento.habitat.nombreHabitat,
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                    if (_distanceInKm != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        '• ${_distanceInKm!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isWithin50Km ? Colors.green[700] : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                // Estado
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getEstadoColor(
                            widget.avistamiento.estadoExtincion,
                          ).withOpacity(0.9),
                          _getEstadoColor(
                            widget.avistamiento.estadoExtincion,
                          ).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Estado: ${widget.avistamiento.estadoExtincion}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onViewDetails,
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('Ver Más'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C6445),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isCalculatingDistance
                            ? null
                            : () {
                                if (widget.onShowRoute != null) {
                                  widget.onShowRoute!();
                                  widget.onClose();
                                } else {
                                  _showRoute();
                                }
                              },
                        icon: _isCalculatingDistance
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.directions, size: 18),
                        label: const Text('Ruta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isWithin50Km
                              ? const Color(0xFF2E7D32)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
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
      if (widget.avistamiento.imagen.startsWith('http')) {
        return Image.network(
          widget.avistamiento.imagen,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholderImage(),
        );
      } else if (widget.avistamiento.imagen.isNotEmpty) {
        return Image.memory(
          base64Decode(widget.avistamiento.imagen),
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
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        widget.avistamiento.especie.toLowerCase() == 'flora'
            ? Icons.local_florist
            : Icons.pets,
        size: 40,
        color: Colors.grey[500],
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
