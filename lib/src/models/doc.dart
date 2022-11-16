import 'element.dart';
import 'header.dart';
import 'node.dart';

class HOCRDoc {
  //final OCRImage? ocrImage;
  final Header header;
  final Map<String, HOCRNode> nodes;

  HOCRDoc({
    //this.ocrImage,
    required this.header,
    required this.nodes,
  });

  HOCRDoc copyWith({
    Header? headerInfo,
    Map<String, HOCRNode>? nodes,
  }) {
    return HOCRDoc(
      //ocrImage: ocrResult ?? ocrImage,
      header: headerInfo ?? header,
      nodes: nodes ?? this.nodes,
    );
  }

  List<HOCRNode> getNested(HOCRNode node) {
    List<HOCRNode> children = node.childrenID.map((e) => nodes[e]!).toList();

    return [
      ...{node, ...children, for (final child in children) ...getNested(child)}
    ];
  }

  HOCRDoc disableList({required List<String> idList, required bool disabled}) {
    final tokens = idList
        .map((e) => getNested(nodes[e]!))
        .expand((i) => i)
        .map((e) => e.id)
        .toSet()
        .toList();

    return copyWith(
        nodes: nodes.map(
      (key, value) => MapEntry(
        key,
        tokens.contains(key)
            ? value.copyWith(
                disabled: disabled,
              )
            : value,
      ),
    ));
  }

  HOCRDoc disable({required String id, required bool disabled}) => disableList(
        idList: [id],
        disabled: disabled,
      );

  bool isDisabled(String id) {
    return nodes[id]?.disabled ?? true;
  }

  replaceText(String id, String text) {
    final nodes = this.nodes;
    if (nodes[id]?.elementType == HOCRElementType.word) {
      nodes[id] = nodes[id]!.copyWith(replacedText: text);
    }
    return copyWith(nodes: nodes);
  }

  List<HOCRNode> get wordNodes => getNodes(HOCRElementType.word);

  List<HOCRNode> getNodes(HOCRElementType block) => nodes.values
      .where((element) =>
          (element.elementType == block) && !element.hidden(getNodeByID))
      .toList();

  HOCRNode? getNodeByID(String id) => nodes[id];

  String getTextByID(String id, bool preserveLineBreak) {
    return nodes[id]?.getText(preserveLineBreak, getNodeByID) ?? "";
  }

  String getText({bool preserveLineBreak = false}) {
    return nodes.keys
        .where((k) => nodes[k]!.parentID == 'root')
        .map((e) => getTextByID(e, preserveLineBreak))
        .join('\n\n');
  }

  bool get isChanged => nodes.values
      .where((HOCRNode e) => e.disabled || e.replacedText != null)
      .isNotEmpty;
}
