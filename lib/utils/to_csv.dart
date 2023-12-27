import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xicmpmt/core/app_logger.dart';

Future<String> toCSV(String name, List<String> headerRow, List<List<String>> listOfListOfStrings, {bool sharing = false}) async {
  AppLogger.debug(name: 'toCSV', 'toCSV start');

  List<List<String>> headerAndDataList = [];
  headerAndDataList.add(headerRow);

  for (var dataRow in listOfListOfStrings) {
    headerAndDataList.add(dataRow);
  }

  final csv = const ListToCsvConverter().convert(headerAndDataList);
  final bytes = utf8.encode(csv);

  Directory? saveDir = await getDownloadsDirectory().catchError((_) => null);
  saveDir ??= await getApplicationDocumentsDirectory();

  String filename = '${saveDir.path}/xicmpmt_$name.csv';
  final File file = File(filename);
  await file.writeAsBytes(bytes, flush: true);
  AppLogger.info(name: 'toCSV', 'toCSV saved: $filename');
  AppLogger.info(name: 'toCSV', 'toCSV size: ${bytes.length} bytes');
  return filename;
}
