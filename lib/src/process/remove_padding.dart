import 'dart:math';

import '../models/box.dart';
import '../models/element.dart';
import '../models/node.dart';

List<HOCRNode> removePadding(List<HOCRNode> nodes) {
  for (final etype in [
    HOCRElementType.line,
    HOCRElementType.par,
    HOCRElementType.carea
  ]) {
    for (int i = 0; i < nodes.length; i++) {
      HOCRNode node = nodes[i];
      if (node.elementType == etype) {
        node = shrinkBoxSize(node, (id) => nodes.firstWhere((e) => e.id == id));
      }
      nodes[i] = node;
    }
  }

  return nodes;
}

HOCRNode shrinkBoxSize(
    final HOCRNode node, HOCRNode? Function(String) getNodeByID) {
  HOCRNode? node2;
  //print("Initial:${Box.fromltrb(node.ltrb2)}");
  if (node.childrenID.isNotEmpty) {
    double? l, t, r, b;
    for (final child in node.childrenID) {
      HOCRNode? childNode = getNodeByID(child);
      if (childNode != null) {
        l = min(childNode.ltrb2.l, l ?? childNode.ltrb2.l);
        t = min(childNode.ltrb2.t, t ?? childNode.ltrb2.t);
        r = min(childNode.ltrb2.r, r ?? childNode.ltrb2.r);
        b = min(childNode.ltrb2.b, b ?? childNode.ltrb2.b);
      }
    }
    if (l != null && t != null && r != null && b != null) {
      final childrenBox = Box(l: l, t: t, r: r, b: b);
      if (node.ltrb2 != childrenBox) {
        //print(node.title);
        node2 =
            node.updateBox(childrenBox.ltrb); // TO DO: we can send box directly
        //print(node2.title);
      }
    }
  }
  /* if (node2 != null) {
      print(
          "${node.elementType.name} node updated ${Box.fromltrb(node.ltrb2)} => ${Box.fromltrb(node2.ltrb2)}");
    } */
  return node2 ?? node;
}

/*
// If the elementType is word, adjust it for associated `line`
    if (node.elementType == hocr.ElementType.word) {
      /* hocr.Node parent = nodes[node.parentID]!;
      List<double>? parentBbox =
          parent.title.properties["bbox"] as List<double>?;
      if (parentBbox != null) {
        ltrb[1] = parentBbox[1];
        ltrb[3] = parentBbox[3];
      } */
    } else if (node.elementType == hocr.ElementType.line) {
      if (node.childrenID.isNotEmpty) {
        /* String firstValidChild = node.childrenID
            .where((element) => !nodes[element]!.iAmHidden)
            .first;
        String lastValidChild =
            node.childrenID.where((element) => !nodes[element]!.iAmHidden).last;
        hocr.Node firstNode = nodes[firstValidChild]!;
        hocr.Node lastChild = nodes[lastValidChild]!;
        if (firstNode.elementType == hocr.ElementType.word) {
          ltrb[0] = firstNode.ltrb2[0];
        }
        if (lastChild.elementType == hocr.ElementType.word) {
          ltrb[2] = lastChild.ltrb2[2];
        } */
      }
    }

extension OCRGeometry on hocr.Doc {
  /* Rect rect({required hocr.Node node, required double scale}) {
    return Rect.fromLTRB(node.ltrb2.l * scale, node.ltrb2.t * scale,
        node.ltrb2.r * scale, node.ltrb2.b * scale);
  } */
}
*/