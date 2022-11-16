import 'package:xml/xml.dart';

import '../models/doc.dart';
import '../models/element.dart';
import '../models/header.dart';
import '../models/node.dart';

extension HeaderExport on Header {
  _toXML(XmlBuilder builder, {Function()? nest}) {
    builder.doctype(name,
        publicId: publicId, systemId: systemId, internalSubset: internalSubset);

    builder.element('html', attributes: htmlAttributes, nest: () {
      builder.element('head', nest: () {
        builder.element('title', nest: () {
          builder.text(title);
        });
        for (Map<String, String> m in meta) {
          builder.element('meta', nest: () {
            for (var e in m.entries) {
              builder.attribute(e.key, e.value);
            }
          });
        }
      });
      nest!.call();
    });
  }
}

extension NodeExport on HOCRNode {
  _toXML(XmlBuilder builder, HOCRNode? Function(String id) getNodeByID) {
    if (!disabled && !hidden(getNodeByID)) {
      builder.element(htmlTag, nest: () {
        builder.attribute("class", elementType.tag);
        builder.attribute("id", id);
        for (MapEntry attr in attributes.entries) {
          builder.attribute(attr.key, attr.value);
        }
        builder.attribute('title', title.pack());
        if (elementType == HOCRElementType.word && word != null) {
          builder.text(word!);
        }

        for (var child in childrenID) {
          getNodeByID(child)!._toXML(builder, getNodeByID);
        }
      });
    } else {
      builder.comment("Text ($htmlTag) deleted here ");
    }
  }
}

extension HOCRExport on HOCRDoc {
  _toXML(XmlBuilder builder) {
    builder.processing('xml', 'version="1.0"  encoding="UTF-8"');
    header._toXML(builder,
        nest: () => builder.element('body', nest: () {
              for (var nodeID in nodes.keys
                  .where((k) => nodes[k]!.parentID == 'root')
                  .toList()) {
                nodes[nodeID]!._toXML(
                    builder, (id) => (id == 'root' ? null : nodes[id]!));
              }
            }));
  }

  XmlDocument get xmlDocument {
    final builder = XmlBuilder();
    _toXML(builder);
    return builder.buildDocument();
  }
}
