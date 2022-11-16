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

List<HOCRNode> discardUbnormalLines(List<HOCRNode> nodes) {
  List<HOCRNode> updatedNodes = nodes;
  for (int i = 0; i < updatedNodes.length; i++) {
    if (updatedNodes[i].elementType == HOCRElementType.par) {
      final node = updatedNodes[i];

      List<HOCRNode> children = node.childrenID
          .map((id) => updatedNodes.firstWhere((e) => e.id == id))
          .toList();
      if (children.isNotEmpty) {
        List<double> heightList = children.map((e) => e.ltrb2.height).toList();
        OutlierRange outlierRange = OutlierRange(heightList);

        for (HOCRNode child in children) {
          final cbox = child.ltrb2;
          if (cbox.height > outlierRange.high ||
              cbox.height < outlierRange.low) {
            updatedNodes[updatedNodes.indexOf(child)] =
                child.copyWith(hidden: true);
          }
        }
      }
    }
  }
  return updatedNodes;
}
