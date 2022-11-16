import 'dart:io';
import 'package:dart_hocr/dart_hocr.dart';

void main(List<String> args) async {
  if (args.isNotEmpty && args.length == 2) {
    // ignore: unused_local_variable
    final doc =
        HOCRImport.fromXMLString(xmlString: File(args[0]).readAsStringSync());
    File(args[1]).writeAsStringSync(doc.xmlDocument.toXmlString());
  } else {
    print("Usage dart_hocr <XML In> <XML out>");
  }
}
