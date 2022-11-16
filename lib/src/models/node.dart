import 'box.dart';
import 'element.dart';
import 'title.dart';

class HOCRNode {
  final String htmlTag;
  final String parentID;
  final List<String> childrenID;
  final Map<String, String> attributes;
  final String? _text;
  final HOCRElementType elementType;
  final String id;
  final bool disabled;
  final bool _hidden;
  final String? replacedText;
  final Title title;
  final Box? boxNormalized;
  HOCRNode(
      {required this.elementType,
      required this.id,
      required this.htmlTag,
      required this.parentID,
      required this.childrenID,
      required this.attributes,
      String? text,
      required this.title,
      String? replacedText,
      this.disabled = false,
      bool hidden = false,
      this.boxNormalized})
      : _text = text,
        _hidden = hidden,
        replacedText = (text == replacedText) ? null : replacedText {
    if (id == "unknown") {
      throw Exception("id must be present for the node");
    }
  }

  HOCRNode copyWith(
      {bool? disabled,
      bool? hidden,
      String? replacedText,
      Title? title,
      Box? boxNormalized}) {
    return HOCRNode(
        elementType: elementType,
        id: id,
        htmlTag: htmlTag,
        parentID: parentID,
        childrenID: childrenID,
        attributes: attributes,
        text: _text,
        title: title ?? this.title,
        replacedText: replacedText ?? this.replacedText,
        disabled: disabled ?? this.disabled,
        hidden: hidden ?? _hidden,
        boxNormalized: boxNormalized ?? this.boxNormalized);
  }

  Box get ltrb2 =>
      boxNormalized ?? Box.fromltrb(title.properties["bbox"] as List<double>);

  HOCRNode? parent(HOCRNode? Function(String) getNodeByID) {
    return getNodeByID(parentID);
  }

  bool get hasChildren => childrenID.isNotEmpty;

  List<HOCRNode?> children(HOCRNode? Function(String) getNodeByID) {
    return childrenID.map((e) => getNodeByID(e)).toList();
  }

  String? get word => replacedText ?? _text;
  String? get originalWord => _text;

  String getText(
      bool preserveLineBreak, HOCRNode? Function(String) getNodeByID) {
    String text = "";
    if (!disabled && !_hidden) {
      if (elementType == HOCRElementType.word) {
        //print("=== ${word ?? ""} === ");
        text = word ?? "";
      } else {
        final sep = (elementType == HOCRElementType.par && preserveLineBreak)
            ? '\n'
            : elementType.seperator;
        // print("$elementType : sep  === $sep ===");
        if (elementType.seperator != sep) {
          print("changed to newline");
        }
        text = childrenID
            .map((e) => getNodeByID(e)!.getText(preserveLineBreak, getNodeByID))
            .join(sep);
      }
    }
    text.replaceAll(RegExp(r'\ *'), ' ');
    //print("$id: === $text ===");
    return text;
  }

  HOCRNode updateBox(List<double> ltrb) {
    return copyWith(title: title.updateBBox(ltrb));
  }

  bool hidden(HOCRNode? Function(String) getNodeByID) {
    if (_hidden) return true;
    HOCRNode? parent = getNodeByID(parentID);
    return parent?.hidden(getNodeByID) ?? false;
  }

  bool get iAmHidden => _hidden;
}
