import 'package:package_config/package_config.dart';
import 'dart:io';
import 'package:dart_hocr/dart_hocr.dart';

void main(List<String> args) async {
  var packageConfig = await findPackageConfig(Directory.current);
  if (packageConfig != null) {
    print(packageConfig.version);
    /* for (var package in packageConfig.packages) {
      print('- ${package.name}');
    } */
  }

  if (args.isNotEmpty && args.length == 2) {
    // ignore: unused_local_variable
    final doc =
        HOCRImport.fromXMLString(xmlString: File(args[0]).readAsStringSync());
    File(args[1]).writeAsStringSync(doc.xmlDocument.toXmlString());
  } else {
    print("Usage dart_hocr <XML In> <XML out>");
  }
}
