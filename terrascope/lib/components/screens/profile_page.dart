import 'package:flutter/material.dart';
import 'package:terrascope/services/auth_service.dart';
import 'package:terrascope/services/session_service.dart';
import 'package:terrascope/components/screens/edit_page.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:terrascope/services/theme_service.dart'; // <--- AGREGAR

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SessionService _sessionService = SessionService();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userData: _userData!),
      ),
    );

    if (result == true) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final sessionData = await _sessionService.getUserData();
      final userId = sessionData?['_id'];

      if (userId == null) {
        setState(() {
          _error = 'No se encontró la sesión del usuario';
          _isLoading = false;
        });
        return;
      }

      final userData = await _authService.obtenerUsuarioPorId(userId);

      if (userData != null) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No se pudieron cargar los datos del usuario';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No especificada';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _userData != null ? _navigateToEdit : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProfile,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_userData == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return RefreshIndicator(
      onRefresh: _loadUserProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            _buildConfigSection(),      
            _buildInfoSection(),
            const SizedBox(height: 24),
            _buildHistorialSection(),
            const SizedBox(height: 24),
            _buildLogrosSection(),
            const SizedBox(height: 24),
            _buildRetosActivosSection(),
            const SizedBox(height: 32),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getImageProvider(String? imagenPerfil) {
    if (imagenPerfil == null || imagenPerfil.isEmpty) return null;

    // Si es base64
    if (imagenPerfil.startsWith('data:image')) {
      final base64String = imagenPerfil.split(',').last;
      return MemoryImage(base64Decode(base64String));
    }

    // Si es URL
    return NetworkImage(imagenPerfil);
  }

  Widget _buildProfileHeader() {
    final imagenPerfil = _userData?['imagen_perfil'];
    final nombre = _userData?['nombre_usuario'] ?? 'Usuario';
    final rol = _userData?['rol']?['nombre_rol'] ?? 'Usuario';
    final imageProvider = _getImageProvider(imagenPerfil);

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.green[100],
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Icon(Icons.person, size: 60, color: Colors.green[700])
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            nombre,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getRolColor(rol),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              rol,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRolColor(String rol) {
    switch (rol) {
      case 'Administrador':
        return Colors.red;
      case 'Investigador':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  Widget _buildConfigSection() {
    // Escuchamos el estado actual del tema
    final themeProvider = context.watch<ThemeProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeProvider.isDarkMode ? Colors.purple[200] : Colors.orange,
              ),
              title: const Text('Modo Oscuro'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                activeColor: Colors.green,
                onChanged: (value) {
                  context.read<ThemeProvider>().toggleTheme(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Personal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow(
              Icons.email,
              'Email',
              _userData?['email_usuario'] ?? 'No especificado',
            ),
            _buildInfoRow(
              Icons.phone,
              'Teléfono',
              _userData?['telefono_usuario'] ?? 'No especificado',
            ),
            _buildInfoRow(
              Icons.cake,
              'Fecha de nacimiento',
              _formatDate(_userData?['fecha_nac_usuario']),
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'Miembro desde',
              _formatDate(_userData?['createdAt']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialSection() {
    final historial = _userData?['historial'];
    if (historial == null) return const SizedBox.shrink();

    final fauna = historial['fauna'] as Map<String, dynamic>? ?? {};
    final flora = historial['flora'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de Registros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.pets, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  'Fauna',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: fauna.entries
                  .map((e) => _buildStatChip(e.key, e.value, Colors.orange))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.local_florist, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Flora',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: flora.entries
                  .map((e) => _buildStatChip(e.key, e.value, Colors.green))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, dynamic value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogrosSection() {
    final logros = _userData?['logros'] as List<dynamic>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Logros',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${logros.length}',
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            if (logros.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Aún no tienes logros',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...logros.map((logro) => _buildLogroItem(logro)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogroItem(Map<String, dynamic> logro) {
    final esMostrado = logro['es_mostrado'] ?? true;

    return ListTile(
      leading: Icon(
        Icons.emoji_events,
        color: esMostrado ? Colors.amber : Colors.grey,
        size: 32,
      ),
      title: Text(logro['nombre_logro'] ?? 'Logro'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (logro['descripcion_titulo'] != null)
            Text(logro['descripcion_titulo']),
          Text(
            'Obtenido: ${_formatDate(logro['fecha_obtencion'])}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      trailing: esMostrado
          ? const Icon(Icons.visibility, color: Colors.green)
          : const Icon(Icons.visibility_off, color: Colors.grey),
    );
  }

  Widget _buildRetosActivosSection() {
    final retos = _userData?['retos_activos'] as List<dynamic>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Retos Activos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${retos.length}',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            if (retos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No tienes retos activos',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...retos
                  .map(
                    (retoId) => ListTile(
                      leading: const Icon(Icons.flag, color: Colors.blue),
                      title: Text('Reto ID: $retoId'),
                    ),
                  )
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar Sesión'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _sessionService.logout();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}
