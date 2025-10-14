import 'package:flutter/material.dart';
import '../../services/fauna_flora_service.dart';
import '../../components/models/avistamiento_model.dart';
import '../map/avistamiento_detail_page.dart';

class AvistamientoDetailLoader extends StatefulWidget {
  final String avistamientoId;
  final FaunaFloraService service;

  const AvistamientoDetailLoader({
    super.key,
    required this.avistamientoId,
    required this.service,
  });

  @override
  State<AvistamientoDetailLoader> createState() =>
      _AvistamientoDetailLoaderState();
}

class _AvistamientoDetailLoaderState extends State<AvistamientoDetailLoader> {
  late Future<Avistamiento?> _avistamientoFuture;

  @override
  void initState() {
    super.initState();
    _avistamientoFuture = widget.service.getFaunaFloraById(
      widget.avistamientoId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Avistamiento?>(
      future: _avistamientoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('No encontrado'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(child: Text('Avistamiento no encontrado')),
          );
        }

        final avistamiento = snapshot.data!;

        // Una vez cargado, mostrar la pantalla de detalle de tu compañero
        return AvistamientoDetailPage(avistamiento: avistamiento);
      },
    );
  }
}
