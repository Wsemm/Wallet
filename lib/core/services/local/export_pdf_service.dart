// import 'dart:typed_data';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// Future<void> generateAndExportPDF() async {
//   final pdf = pw.Document();

//   // Add pages into the document structure
//   pdf.addPage(
//     pw.MultiPage(
//       pageFormat: PdfPageFormat.a4,
//       build: (pw.Context context) {
//         return [
//           pw.Header(level: 0, child: pw.Text("Sales Invoice Summary")),
//           pw.SizedBox(height: 20),

//           // Generate a custom formatted grid or table inside your layout
//           pw.TableHelper.fromTextArray(
//             headers: ['ID', 'Item Description', 'Cost'],
//             data: [
//               ['101', 'Cloud Hosting Premium', '\$120.00'],
//               ['102', 'Domain Registration', '\$15.00'],
//               ['103', 'SSL Certificate', '\$45.00'],
//             ],
//             headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//             cellAlignment: pw.Alignment.centerLeft,
//           ),
//         ];
//       },
//     ),
//   );

//   // Use the printing package to launch an interactive OS sharing modal
//   // or print dialogue. Works flawlessly on Android, iOS, Web, and Desktop.
//   await Printing.layoutPdf(
//     onLayout: (PdfPageFormat format) async => pdf.save(),
//   );
// }
