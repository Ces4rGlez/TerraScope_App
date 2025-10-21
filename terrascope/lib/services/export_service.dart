import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../components/models/avistamiento_model.dart';

class ExportService {
  /// Exportar avistamientos a Excel (versión 2.0.1)
  Future<File?> exportToExcel(List<Avistamiento> avistamientos) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Avistamientos'];

      // Encabezados
      List<String> headers = [
        'Nombre Común',
        'Nombre Científico',
        'Tipo',
        'Especie',
        'Descripción',
        'Comportamiento',
        'Estado Extinción',
        'Estado Espécimen',
        'Latitud',
        'Longitud',
        'Hábitat',
        'Descripción Hábitat',
        'Usuario',
        'Total Comentarios',
      ];

      // Agregar encabezados
      for (int i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = headers[i];
      }

      // Agregar datos
      for (int rowIndex = 0; rowIndex < avistamientos.length; rowIndex++) {
        final avistamiento = avistamientos[rowIndex];

        final rowData = [
          avistamiento.nombreComun ?? '',
          avistamiento.nombreCientifico ?? '',
          avistamiento.tipo ?? '',
          avistamiento.especie ?? '',
          avistamiento.descripcion ?? '',
          avistamiento.comportamiento ?? '',
          avistamiento.estadoExtincion ?? '',
          avistamiento.estadoEspecimen ?? '',
          avistamiento.ubicacion.latitud.toString(),
          avistamiento.ubicacion.longitud.toString(),
          avistamiento.habitat.nombreHabitat ?? '',
          avistamiento.habitat.descripcionHabitat ?? '',
          avistamiento.nombreUsuario ?? '',
          (avistamiento.comentarios?.length ?? 0).toString(),
        ];

        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          var cell = sheetObject.cell(
            CellIndex.indexByColumnRow(
              columnIndex: colIndex,
              rowIndex: rowIndex + 1,
            ),
          );
          cell.value = rowData[colIndex];
        }
      }

      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/avistamientos_$timestamp.xlsx';

      final fileBytes = excel.encode();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        await _openFile(file);
        return file;
      }

      return null;
    } catch (e) {
      print('Error exportando a Excel: $e');
      rethrow;
    }
  }

  /// Resto de los métodos permanecen igual...
  String generateCSV(List<Avistamiento> avistamientos) {
    StringBuffer csv = StringBuffer();

    // Encabezados
    csv.writeln(
      'Nombre Común,Nombre Científico,Tipo,Especie,Descripción,Comportamiento,'
      'Estado Extinción,Estado Espécimen,Latitud,Longitud,Hábitat,'
      'Descripción Hábitat,Usuario,Total Comentarios',
    );

    // Datos
    for (var avistamiento in avistamientos) {
      csv.writeln(
        '${_escapeCsv(avistamiento.nombreComun ?? '')},'
        '${_escapeCsv(avistamiento.nombreCientifico ?? '')},'
        '${_escapeCsv(avistamiento.tipo ?? '')},'
        '${_escapeCsv(avistamiento.especie ?? '')},'
        '${_escapeCsv(avistamiento.descripcion ?? '')},'
        '${_escapeCsv(avistamiento.comportamiento ?? '')},'
        '${_escapeCsv(avistamiento.estadoExtincion ?? '')},'
        '${_escapeCsv(avistamiento.estadoEspecimen ?? '')},'
        '${avistamiento.ubicacion.latitud},'
        '${avistamiento.ubicacion.longitud},'
        '${_escapeCsv(avistamiento.habitat.nombreHabitat ?? '')},'
        '${_escapeCsv(avistamiento.habitat.descripcionHabitat ?? '')},'
        '${_escapeCsv(avistamiento.nombreUsuario ?? '')},'
        '${avistamiento.comentarios?.length ?? 0}',
      );
    }

    return csv.toString();
  }

  Future<File?> saveCSV(String csvContent) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/avistamientos_$timestamp.csv';

      final file = File(filePath);
      await file.writeAsString(csvContent, flush: true);
      await _openFile(file);
      return file;
    } catch (e) {
      print('Error guardando CSV: $e');
      rethrow;
    }
  }

  Future<void> _openFile(File file) async {
    try {
      final result = await OpenFile.open(file.path);

      switch (result.type) {
        case ResultType.done:
          print('Archivo abierto exitosamente: ${file.path}');
          break;
        case ResultType.noAppToOpen:
          print('No hay aplicación para abrir este tipo de archivo');
          break;
        case ResultType.fileNotFound:
          print('Archivo no encontrado: ${file.path}');
          break;
        case ResultType.permissionDenied:
          print('Permiso denegado para abrir: ${file.path}');
          break;
        case ResultType.error:
          print('Error al abrir el archivo: ${result.message}');
          break;
      }
    } catch (e) {
      print('Error al abrir archivo: $e');
    }
  }

  /// Exportar avistamientos a PDF
  Future<File?> exportToPDF(List<Avistamiento> avistamientos) async {
    try {
      final pdf = pw.Document();

      // Crear tabla de datos
      final headers = [
        'Nombre Común',
        'Nombre Científico',
        'Tipo',
        'Especie',
        'Descripción',
        'Comportamiento',
        'Estado Extinción',
        'Estado Espécimen',
        'Latitud',
        'Longitud',
        'Hábitat',
        'Descripción Hábitat',
        'Usuario',
        'Total Comentarios',
      ];

      final data = avistamientos.map((avistamiento) {
        return [
          avistamiento.nombreComun ?? '',
          avistamiento.nombreCientifico ?? '',
          avistamiento.tipo ?? '',
          avistamiento.especie ?? '',
          avistamiento.descripcion ?? '',
          avistamiento.comportamiento ?? '',
          avistamiento.estadoExtincion ?? '',
          avistamiento.estadoEspecimen ?? '',
          avistamiento.ubicacion.latitud.toString(),
          avistamiento.ubicacion.longitud.toString(),
          avistamiento.habitat.nombreHabitat ?? '',
          avistamiento.habitat.descripcionHabitat ?? '',
          avistamiento.nombreUsuario ?? '',
          (avistamiento.comentarios?.length ?? 0).toString(),
        ];
      }).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Avistamientos TerraScope',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total de registros: ${avistamientos.length}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: headers,
                data: data,
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.centerLeft,
                  5: pw.Alignment.centerLeft,
                  6: pw.Alignment.center,
                  7: pw.Alignment.center,
                  8: pw.Alignment.center,
                  9: pw.Alignment.center,
                  10: pw.Alignment.centerLeft,
                  11: pw.Alignment.centerLeft,
                  12: pw.Alignment.centerLeft,
                  13: pw.Alignment.center,
                },
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Generado el ${DateTime.now().toString()}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ];
          },
        ),
      );

      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/avistamientos_$timestamp.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      await _openFile(file);
      return file;
    } catch (e) {
      print('Error exportando a PDF: $e');
      rethrow;
    }
  }

  String _escapeCsv(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
