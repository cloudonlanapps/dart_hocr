import 'models/doc.dart';
import 'xml/xml_import.dart';

String getRawText({required String xmlString}) {
  final HOCRDoc doc = HOCRImport.fromXMLString(xmlString: xmlString);
  return doc.getText();
}
