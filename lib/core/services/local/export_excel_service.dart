import 'dart:developer';
import 'dart:io';

import 'package:excel_plus/excel_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:wallet/main.dart';

Future<void> exportToExcel({
  required List<Map<String, dynamic>> data,
  required List<Map<String, dynamic>> summary,
  BuildContext? context,
}) async {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel['Sheet1'];

  // 1. Define your Header Style (Dark Blue Background, White Bold Text)
  CellStyle headerStyle = CellStyle(
    backgroundColorHex: ExcelColor.fromHexString(
      '#1F4E78',
    ), // Professional Navy
    fontColorHex: ExcelColor.white, // White text
    fontFamily: getFontFamily(FontFamily.Calibri),
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );
  CellStyle headerStyleBlue = CellStyle(
    backgroundColorHex: ExcelColor.blue,
    fontColorHex: ExcelColor.white,
    fontFamily: getFontFamily(FontFamily.Calibri),
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );
  CellStyle headerStyleRed = CellStyle(
    backgroundColorHex: ExcelColor.red,
    fontColorHex: ExcelColor.white,
    fontFamily: getFontFamily(FontFamily.Calibri),
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );
  CellStyle headerStyleOrange = CellStyle(
    backgroundColorHex: ExcelColor.orange,
    fontColorHex: ExcelColor.white,
    fontFamily: getFontFamily(FontFamily.Calibri),
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );
  CellStyle headerStyleGreen = CellStyle(
    backgroundColorHex: ExcelColor.green,
    fontColorHex: ExcelColor.white,
    fontFamily: getFontFamily(FontFamily.Calibri),
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );

  // 2. Define your Data Row Style (Optional: light gray borders or custom font)
  CellStyle dataStyle = CellStyle(
    fontFamily: getFontFamily(FontFamily.Calibri),
    horizontalAlign: HorizontalAlign.Left,
  );

  // 3. Add Header Row with styling
  List<CellValue> headers = [
    TextCellValue('ID'),
    TextCellValue('Title'),
    TextCellValue('Amount'),
    TextCellValue('Type'),
    TextCellValue('Category'),
    TextCellValue('Note'),
    TextCellValue('CreatedAt'),
    TextCellValue('Group ID'),
    TextCellValue('Group Name'),
    TextCellValue('Group Desc'),
  ];

  sheetObject.appendRow(headers);

  // Apply style to the header row (Row index 0)
  for (int col = 0; col < headers.length; col++) {
    sheetObject.updateCell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
      headers[col],
      cellStyle: headerStyle,
    );
  }

  // 4. Add Data Rows
  int currentRowIndex = 1;

  for (var row in data) {
    List<CellValue?> rowData = [
      IntCellValue(row['id']),
      TextCellValue(row['title']),
      DoubleCellValue(row['amount']),
      TextCellValue(row['type']),
      TextCellValue(row['category']),
      row['note'] != null ? TextCellValue(row['note']) : null,
      TextCellValue(row['createdAt']),
      row['groupId'] != null ? IntCellValue(row['groupId']) : null,
      row['groupName'] != null ? TextCellValue(row['groupName']) : null,
      row['groupDesc'] != null ? TextCellValue(row['groupDesc']) : null,
    ];

    sheetObject.appendRow(rowData);

    // Apply data style to the row
    for (int col = 0; col < rowData.length; col++) {
      if (rowData[col] != null) {
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: currentRowIndex,
          ),
          rowData[col]!,
          cellStyle: dataStyle,
        );
      }
    }

    currentRowIndex++;
  }

  // =======================================================
  // CREATE SPACE HERE (After Data Rows & Before Summary Data)
  // =======================================================
  sheetObject.appendRow([]);
  sheetObject.appendRow([]);
  currentRowIndex += 2; // Jump the index pointer by 2 rows

  // 5. Add Summary Rows
  for (var row in summary) {
    List<CellValue?> rowData = [
      DoubleCellValue(row['totalIncome']),
      DoubleCellValue(row['totalExpense']),
      DoubleCellValue(row['totalDebits']),
      DoubleCellValue(row['totalBalance']),
      DoubleCellValue(row['totalPeopleDebits']),
    ];

    sheetObject.appendRow(rowData);

    // Apply data style to the row
    for (int col = 0; col < rowData.length; col++) {
      if (rowData[col] != null) {
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: currentRowIndex,
          ),
          rowData[col]!,
          cellStyle: switch (col) {
            0 => headerStyleGreen,
            1 => headerStyleRed,
            2 => headerStyleOrange,
            3 => headerStyleRed,
            4 => headerStyleBlue,
            int() => throw UnimplementedError(),
          },
        );
      }
    }

    currentRowIndex++;
  }

  // 6. Design UI Adjustments: Set custom column widths so text doesn't clip
  sheetObject.setColumnWidth(1, 25.0); // Title column wider
  sheetObject.setColumnWidth(5, 30.0); // Note column wider
  sheetObject.setColumnWidth(6, 20.0); // CreatedAt column wider

  // 7. Save file
  // var fileBytes = excel.save();
  // Directory? extDir = await getExternalStorageDirectory();
  // if (extDir != null) {
  //   String appFolderBatchPath = "${extDir.path}/Product_Report.xlsx";

  //   File(appFolderBatchPath)
  //     ..createSync(recursive: true)
  //     ..writeAsBytesSync(fileBytes!);

  //   log("Excel successfully saved with design: $appFolderBatchPath");
  // }

  saveExcelToDownloads(excel, context);
}

Future<void> saveExcelToDownloads(var excel, BuildContext? context) async {
  // 1. توليد مصفوفة البايتات من ملف الإكسل عبر حزمة excel_plus
  var fileBytes = excel.save();

  if (fileBytes == null) {
    log("Error: Excel bytes are null");
    return;
  }

  String? downloadsPath;

  if (Platform.isAndroid) {
    // المسار العام لمجلد التنزيلات في أندرويد
    downloadsPath = "/storage/emulated/0/Download";
  } else if (Platform.isIOS) {
    // في الآيفون، نستخدم مجلد المستندات الخاص بالتطبيق ليظهر في تطبيق Files
    final documentsDir = await getApplicationDocumentsDirectory();
    downloadsPath = documentsDir.path;
  }

  if (downloadsPath != null) {
    // دمج المسار واسم الملف باستخدام حزمة path الممررة لديك
    String fullPath = p.join(downloadsPath, "Wallet_Report.xlsx");

    try {
      final file = File(fullPath);

      // إنشاء الملف وكتابة البيانات دفعة واحدة
      await file.create(recursive: true);
      await file.writeAsBytes(fileBytes);

      log("Excel successfully saved to Downloads: $fullPath");
      ScaffoldMessenger.of(
        context ?? navigatorKey.currentContext!,
      ).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text("Excel successfully saved to Downloads: $fullPath"),
            ],
          ),
        ),
      );
    } catch (e) {
      log("Failed to save file: $e");
    }
  }
}
