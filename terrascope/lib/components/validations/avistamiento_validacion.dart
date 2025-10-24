import 'package:flutter/material.dart';
import 'dart:developer';
import '../../services/fauna_flora_service.dart';
import '../../services/session_service.dart';
import '../models/avistamiento_model.dart';

/// 🧩 Gestiona la lógica de validación de avistamientos
/// y centraliza el consumo de FaunaFloraService.
class AvistamientoValidacionProvider with ChangeNotifier {
  final FaunaFloraService _service;
  final SessionService _sessionService = SessionService();

  AvistamientoValidacionProvider({required String baseUrl})
    : _service = FaunaFloraService(baseUrl: baseUrl);

  /// Lista de avistamientos
  List<Avistamiento> _avistamientos = [];
  List<Avistamiento> get avistamientos => _avistamientos;

  /// Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error actual
  String? _error;
  String? get error => _error;

  /// 🔹 Cargar todos los avistamientos
  Future<void> cargarAvistamientos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log("📦 Cargando lista de avistamientos...");
      _avistamientos = await _service.getAllFaunaFlora();
      log("✅ Avistamientos cargados: ${_avistamientos.length}");
    } catch (e) {
      _error = 'Error al cargar avistamientos: $e';
      log("❌ $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🗳️ Votar validación comunitaria
  Future<void> votar(String idAvistamiento) async {
    try {
      log("🗳️ Iniciando proceso de voto para avistamiento $idAvistamiento...");
      final userData = await _sessionService.getUserData();

      // 🔍 Verificar datos en sesión
      log("🔍 Datos de sesión al votar: $userData");

      if (userData == null || userData['_id'] == null) {
        throw Exception(
          '⚠️ No se encontró el usuario en sesión o falta el _id',
        );
      }

      final idUsuario = userData['_id'];
      log(
        "📤 Enviando voto de usuario $idUsuario → avistamiento $idAvistamiento",
      );

      await _service.votarAvistamiento(idAvistamiento, idUsuario);

      log("✅ Voto enviado correctamente. Recargando lista...");
      await cargarAvistamientos();
    } catch (e) {
      _error = 'Error al votar: $e';
      log("❌ $_error");
      notifyListeners();
    }
  }

  /// 🧠 Validar avistamiento como experto (solo Administrador o Investigador)
  Future<void> validarComoExperto(String idAvistamiento) async {
    try {
      log(
        "🧠 Iniciando validación de experto para avistamiento $idAvistamiento...",
      );
      final userData = await _sessionService.getUserData();

      // 🔍 Mostrar datos completos del usuario
      log("🔍 Datos de sesión al validar como experto: $userData");

      if (userData == null ||
          userData['_id'] == null ||
          userData['rol'] == null) {
        throw Exception(
          '⚠️ No se encontró información válida de usuario o rol',
        );
      }

      final idUsuario = userData['_id'];
      final rol = userData['rol'];
      log("📤 Enviando validación como experto → usuario $idUsuario ($rol)");

      await _service.validarComoExperto(idAvistamiento, idUsuario, rol);

      log("✅ Validación por experto exitosa. Recargando lista...");
      await cargarAvistamientos();
    } catch (e) {
      _error = 'Error al validar como experto: $e';
      log("❌ $_error");
      notifyListeners();
    }
  }

  /// 🔍 Obtener estado actual de validación (con yaVoto)
  Future<Map<String, dynamic>?> obtenerEstadoValidacion(
    String idAvistamiento,
  ) async {
    try {
      log("📡 Consultando estado de validación para $idAvistamiento...");

      final userData = await _sessionService.getUserData();
      if (userData == null || userData['_id'] == null) {
        throw Exception('⚠️ No se encontró usuario en sesión');
      }

      final idUsuario = userData['_id'];
      log("👤 Usuario en sesión: $idUsuario");

      // 🔹 Llamada al service pasando userId
      final estado = await _service.getEstadoValidacion(
        idAvistamiento,
        idUsuario,
      );

      if (estado != null) {
        final yaVoto = estado['yaVoto'] ?? false;
        final votos = estado['votos_comunidad'] ?? 0;
        final requeridos = estado['requeridos_comunidad'] ?? 0;
        final validado = estado['validado_por_experto'] ?? false;

        log(
          "📊 Estado recibido → votos: $votos, requeridos: $requeridos, validado: $validado, yaVoto: $yaVoto",
        );
      }

      return estado;
    } catch (e) {
      _error = 'Error al obtener validación: $e';
      log("❌ $_error");
      notifyListeners();
      return null;
    }
  }
}
