import 'package:xml/xml.dart';

import '../models/doc.dart';
import '../models/element.dart';
import '../models/header.dart';
import '../models/node.dart';
import '../models/title.dart';
import '../process/align_words_in_line.dart';
import '../process/discard_ubnormal_lines.dart';

extension HeaderImport on Header {
  static Header _fromXML(
      {required XmlDoctype doctype, required XmlElement root}) {
    if (root.name.toString() != 'html') {
      throw Exception("The root element is not html, but ${root.name}");
    }

    final XmlElement head = root.findAllElements('head').first;
    final String title = head.findAllElements('title').first.text;

    return Header(
        name: doctype.name,
        publicId: doctype.externalId?.publicId,
        systemId: doctype.externalId?.systemId,
        internalSubset: doctype.internalSubset,
        htmlAttributes: Map.fromEntries(root.attributes
            .map((p0) => MapEntry(p0.name.toString(), p0.value))),
        title: title,
        meta: head.findAllElements('meta').map(
          (XmlElement e) {
            return Map.fromEntries(e.attributes
                .map((p0) => MapEntry(p0.name.toString(), p0.value)));
          },
        ).toList());
  }
}

extension NodeImport on HOCRNode {
  static HOCRNode _fromXML(XmlElement xmlElement) {
    final children = xmlElement.children
        .where((p0) => HOCRElementType.tags.contains(p0.getAttribute('class')))
        .map((p0) => p0.getAttribute('id') ?? "Error: HOCR FAIL")
        .toList();

    return HOCRNode(
        htmlTag: xmlElement.name.toString(),
        attributes: {
          for (var e in xmlElement.attributes.where(
            (p0) => !["title", "class", "id"].contains(p0.name.toString()),
          ))
            (e).name.toString(): (e).value
        },
        elementType: HOCRElementType.fromTag(xmlElement.getAttribute('class')!),
        id: xmlElement.getAttribute('id') ?? "unknown",
        title: Title(xmlElement.getAttribute('title') ?? ""),
        parentID: xmlElement.parent?.getAttribute('id') ?? 'root',
        childrenID: children,
        text: children.isEmpty && xmlElement.text.isNotEmpty
            ? xmlElement.text
            : null);
  }
}

extension HOCRImport on HOCRDoc {
  static List<HOCRNode> _nodesfromXML(XmlDocument xmlDocument) {
    final body = xmlDocument.findAllElements('body').first;

    final nodes_ = body.descendants
        .where((p0) => HOCRElementType.tags.contains(p0.getAttribute('class')))
        .map((e) => NodeImport._fromXML(e as XmlElement))
        .toList();

    _integrityCheck(nodes_);

    return nodes_;
  }

  /// Scenaris where the node is hidden:
  /// 1. if the items is outside its parent, ideally, this should not have occured
  ///   but tessearact generates such elements
  /// 2. box widht is too small, of less than 20
  ///   the value 20 is just a random, should find the optimal calculation
  ///
  static List<HOCRNode> _integrityCheck(List<HOCRNode> nodes) {
    for (int i = 0; i < nodes.length; i++) {
      HOCRNode node = nodes[i];
      if (node.parentID != 'root') {
        HOCRNode? parent = nodes.firstWhere((e) => e.id == node.parentID);
        if (node.ltrb2.isOutside(parent.ltrb2)) {
          node = node.copyWith(hidden: true);
        }
      }
      if (node
          .getText(false, (id) => nodes.firstWhere((e) => e.id == id))
          .isEmpty) {
        node = node.copyWith(hidden: true);
      }
      if (node.elementType == HOCRElementType.word) {
        final box = node.ltrb2;
        if ((box.r - box.l) < 20) {
          node = node.copyWith(hidden: true);
        }
      }
      /* if (node.elementType == ElementType.word) {
        print('${node.text} x wconf: ${node.properties['x_wconf']}');

        // Need to finetune this hardcoded 40
        if ((node.properties['x_wconf'] ?? 0.0) < 10) {
          nodes[i] = node.copyWith(disabled: true);
        }
      } */

      nodes[i] = node;
    }

    nodes = alignWordsInLine(nodes);
    nodes = discardUbnormalLines(nodes);

    //  nodes = hideOutliers(nodes);
    //nodes = removePadding(nodes);
    return nodes;
  }

  static HOCRDoc fromXMLString({required String xmlString}) {
    final xmlDocument = XmlDocument.parse(xmlString);
    Header header = HeaderImport._fromXML(
        doctype: xmlDocument.doctypeElement!, root: xmlDocument.rootElement);
    final doc = HOCRDoc(
      //ocrImage: ocrImage,
      header: header,
      nodes: {for (var e in _nodesfromXML(xmlDocument)) e.id: e},
    );

    return doc;
  }
}
