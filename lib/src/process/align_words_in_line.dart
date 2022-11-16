import '../models/box.dart';
import '../models/element.dart';
import '../models/node.dart';
import 'outlier.dart';

/// Align words to the line boundary:
/// Issues:
///     Line can have text of different size, hence the heigth could be
///     much higher, due to outliers.
///     Algo:
///       adjust the line hight excluding outliers.
///       apply the line top and bottom to all its children

List<HOCRNode> alignWordsInLine(List<HOCRNode> nodes) {
  List<HOCRNode> updatedNodes = nodes;
  for (int i = 0; i < updatedNodes.length; i++) {
    if (updatedNodes[i].elementType == HOCRElementType.line) {
      final node = updatedNodes[i];
      Box box = node.ltrb2;
      List<HOCRNode> children = node.childrenID
          .map((id) => updatedNodes.firstWhere((e) => e.id == id))
          .toList();
      if (children.isNotEmpty) {
        List<double> heightList = children.map((e) => e.ltrb2.height).toList();
        OutlierRange outlierRange = OutlierRange(heightList);
        if (box.height > outlierRange.high) {
          updatedNodes[i] = node.copyWith(
              boxNormalized:
                  node.ltrb2.copyWith(b: node.ltrb2.t + outlierRange.high));
        }
        final pbox = node.ltrb2;

        for (HOCRNode child in children) {
          final cbox = child.ltrb2;
          updatedNodes[updatedNodes.indexOf(child)] = child.copyWith(
              boxNormalized: Box(
            l: cbox.l,
            t: pbox.t,
            r: cbox.r,
            b: pbox.b,
          ));
        }
      }
    }
  }
  return updatedNodes;
}
