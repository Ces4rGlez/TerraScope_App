import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../components/models/ubicacion.dart';

class LocationService {
  // Solicitar permisos de ubicación
  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.request();
    return status.isGranted;
  }

  // Verificar si los servicios de ubicación están habilitados
  Future<bool> checkLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled;
  }

  // Obtener ubicación actual
  Future<Ubicacion?> getCurrentLocation() async {
    try {
      if (!await checkLocationServices()) {
        throw Exception('Los servicios de ubicación están deshabilitados');
      }

      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Permiso de ubicación denegado');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      return Ubicacion(
        latitud: position.latitude,
        longitud: position.longitude,
      );
    } catch (e) {
      // En lugar de print, lanza la excepción para manejarla en la UI
      rethrow;
    }
  }

  // Obtener distancia entre dos puntos (en kilómetros)
  double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convertir a km
  }

  // Verificar el estado de los permisos sin solicitarlos
  Future<bool> hasLocationPermission() async {
    var status = await Permission.location.status;
    return status.isGranted;
  }

  // Abrir configuración de la app
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}