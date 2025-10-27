import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../components/models/avistamiento_model.dart';

class ExportService {
  /// Exportar avistamientos a Excel
  Future<File?> exportToExcel(List<Avistamiento> avistamientos) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Avistamientos'];

      // Estilos mejorados con paleta de colores
      final headerStyle = CellStyle(
        bold: true,
        fontSize: 12,
        fontColorHex: 'FFFFFF',
        backgroundColorHex: '0f1d33', // Azul oscuro principal
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final subHeaderStyle = CellStyle(
        bold: true,
        fontSize: 10,
        fontColorHex: 'FFFFFF',
        backgroundColorHex: '224275', // Azul medio
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final dataStyle = CellStyle(
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Left,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: 'FFFFFF',
      );

      final dataStyleAlt = CellStyle(
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Left,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: 'F5F5F5', // Gris muy claro para filas alternas
      );

      final numberStyle = CellStyle(
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: 'FFFFFF',
      );

      final numberStyleAlt = CellStyle(
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: 'F5F5F5',
      );

      final accentStyle = CellStyle(
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        fontColorHex: '5c6445', // Verde principal para textos destacados
        bold: true,
      );

      // Título principal (fila 0)
      var titleCell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      );
      titleCell.value = 'REPORTE DE AVISTAMIENTOS - TERRASCOPE';
      titleCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
        fontColorHex: 'FFFFFF',
        backgroundColorHex: '5c6445', // Verde principal
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
      sheetObject.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 0),
      );

      // Información del reporte (fila 1)
      var infoCell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      );
      infoCell.value =
          'Generado: ${DateTime.now().toLocal().toString().split('.')[0]} | Total de registros: ${avistamientos.length}';
      infoCell.cellStyle = CellStyle(
        fontSize: 10,
        fontColorHex: '224275',
        backgroundColorHex: 'e0e0e0',
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
      sheetObject.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
        CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 1),
      );

      // Encabezados principales
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
        'Comentarios',
      ];

      // Agregar encabezados con estilo
      for (int i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3),
        );
        cell.value = headers[i];
        cell.cellStyle = headerStyle;
      }

      // Agregar datos con filas alternas
      for (int rowIndex = 0; rowIndex < avistamientos.length; rowIndex++) {
        final avistamiento = avistamientos[rowIndex];
        final isEvenRow = rowIndex % 2 == 0;

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
              rowIndex: rowIndex + 4, // +4 para dejar espacio al título e info
            ),
          );
          cell.value = rowData[colIndex];

          // Aplicar estilo según tipo de dato y fila
          if (colIndex == 8 || colIndex == 9 || colIndex == 13) {
            cell.cellStyle = isEvenRow ? numberStyle : numberStyleAlt;
          } else {
            cell.cellStyle = isEvenRow ? dataStyle : dataStyleAlt;
          }
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

  /// Exportar avistamientos a PDF (versión mejorada con diseño profesional)
  Future<File?> exportToPDF(List<Avistamiento> avistamientos) async {
    try {
      final pdf = pw.Document();

      // Paleta de colores
      final primaryGreen = PdfColor.fromHex('#224275');
      final secondaryGreen = PdfColor.fromHex('#939e69');
      final darkBlue = PdfColor.fromHex('#5c6445');
      final mediumBlue = PdfColor.fromHex('#939e69');
      final lightGray = PdfColor.fromHex('#e0e0e0');

      final headers = [
        'Nombre\nComún',
        'Nombre\nCientífico',
        'Tipo',
        'Especie',
        'Descripción',
        'Comportamiento',
        'Estado\nExtinción',
        'Estado\nEspécimen',
        'Lat.',
        'Long.',
        'Hábitat',
        'Desc.\nHábitat',
        'Usuario',
        'Com.',
      ];

      final data = avistamientos.map((avistamiento) {
        return [
          avistamiento.nombreComun ?? '',
          avistamiento.nombreCientifico ?? '',
          avistamiento.tipo ?? '',
          avistamiento.especie ?? '',
          _truncateText(avistamiento.descripcion ?? '', 50),
          _truncateText(avistamiento.comportamiento ?? '', 40),
          avistamiento.estadoExtincion ?? '',
          avistamiento.estadoEspecimen ?? '',
          avistamiento.ubicacion.latitud.toStringAsFixed(4),
          avistamiento.ubicacion.longitud.toStringAsFixed(4),
          avistamiento.habitat.nombreHabitat ?? '',
          _truncateText(avistamiento.habitat.descripcionHabitat ?? '', 40),
          avistamiento.nombreUsuario ?? '',
          (avistamiento.comentarios?.length ?? 0).toString(),
        ];
      }).toList();

      // Calcular estadísticas
      final totalComentarios = avistamientos.fold(
        0,
        (sum, item) => sum + (item.comentarios?.length ?? 0),
      );
      final especiesUnicas = avistamientos
          .map((e) => e.especie)
          .where((e) => e != null && e.isNotEmpty)
          .toSet()
          .length;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          header: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [darkBlue, mediumBlue],
                  begin: pw.Alignment.centerLeft,
                  end: pw.Alignment.centerRight,
                ),
                borderRadius: const pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(10),
                  topRight: pw.Radius.circular(10),
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TERRASCOPE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Reporte de Avistamientos',
                        style: pw.TextStyle(fontSize: 12, color: lightGray),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      color: primaryGreen,
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Text(
                      'Pág. ${context.pageNumber}/${context.pagesCount}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          footer: (pw.Context context) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(top: 10),
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: lightGray, width: 2),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generado: ${DateTime.now().toLocal().toString().split('.')[0]}',
                    style: pw.TextStyle(fontSize: 9, color: mediumBlue),
                  ),
                  pw.Text(
                    'TerraScope © 2025',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: primaryGreen,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
          build: (pw.Context context) {
            return [
              // Panel de estadísticas
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [PdfColor.fromHex('#f8f9fa'), lightGray],
                    begin: pw.Alignment.topLeft,
                    end: pw.Alignment.bottomRight,
                  ),
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: primaryGreen, width: 2),
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Resumen Ejecutivo',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'Total de Registros',
                            '${avistamientos.length}',
                            primaryGreen,
                            darkBlue,
                          ),
                          _buildStatCard(
                            'Especies Únicas',
                            '$especiesUnicas',
                            mediumBlue,
                            darkBlue,
                          ),
                          _buildStatCard(
                            'Total Comentarios',
                            '$totalComentarios',
                            secondaryGreen,
                            darkBlue,
                          ),
                          _buildStatCard(
                            'Promedio Comentarios',
                            avistamientos.isNotEmpty
                                ? (totalComentarios / avistamientos.length)
                                      .toStringAsFixed(1)
                                : '0',
                            PdfColor.fromHex('#6c757d'),
                            darkBlue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Tabla de datos
              pw.Table.fromTextArray(
                headers: headers,
                data: data,
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8,
                  color: PdfColors.white,
                ),
                cellStyle: const pw.TextStyle(fontSize: 7),
                headerDecoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(colors: [darkBlue, mediumBlue]),
                ),
                border: pw.TableBorder.all(color: lightGray, width: 1),
                cellHeight: 28,
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.2),
                  1: const pw.FlexColumnWidth(1.3),
                  2: const pw.FlexColumnWidth(0.8),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(1.5),
                  5: const pw.FlexColumnWidth(1.3),
                  6: const pw.FlexColumnWidth(1),
                  7: const pw.FlexColumnWidth(1),
                  8: const pw.FlexColumnWidth(0.7),
                  9: const pw.FlexColumnWidth(0.7),
                  10: const pw.FlexColumnWidth(1),
                  11: const pw.FlexColumnWidth(1.3),
                  12: const pw.FlexColumnWidth(1),
                  13: const pw.FlexColumnWidth(0.6),
                },
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.centerLeft,
                  5: pw.Alignment.centerLeft,
                  6: pw.Alignment.center,
                  7: pw.Alignment.center,
                  8: pw.Alignment.centerRight,
                  9: pw.Alignment.centerRight,
                  10: pw.Alignment.centerLeft,
                  11: pw.Alignment.centerLeft,
                  12: pw.Alignment.centerLeft,
                  13: pw.Alignment.center,
                },
                oddRowDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#f8f9fa'),
                ),
                rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
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

  // Widget auxiliar para tarjetas de estadísticas
  pw.Widget _buildStatCard(
    String label,
    String value,
    PdfColor accentColor,
    PdfColor textColor,
  ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: accentColor, width: 2),
          boxShadow: [
            pw.BoxShadow(
              color: PdfColor.fromHex('#00000020'),
              offset: const PdfPoint(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: pw.Column(
          children: [
            pw.Text(
              label,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 9, color: textColor),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función auxiliar para truncar texto
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
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
