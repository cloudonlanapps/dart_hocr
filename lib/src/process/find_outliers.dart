// Expect the

import '../models/element.dart';
import '../models/node.dart';

List<HOCRNode> hideOutliers(List<HOCRNode> nodes) {
  List<double> lineHeight = [];
  for (int i = 0; i < nodes.length; i++) {
    if (nodes[i].elementType == HOCRElementType.line) {
      lineHeight.add(nodes[i].ltrb2.height);
    }
  }

  final sortedList = List.from(lineHeight);
  sortedList.sort((a, b) => a.compareTo(b));

  final q1 = (lineHeight.length * 0.25).round();
  final q2 = (lineHeight.length * 0.5).round();
  final q3 = (lineHeight.length * 0.75).round();

  final gap = sortedList[q3] - sortedList[q1];

  final minvalue = sortedList[q2] - 2 * gap;
  final maxValue = sortedList[q2] + 2 * gap;

  for (int i = 0; i < nodes.length; i++) {
    if (nodes[i].elementType == HOCRElementType.line) {
      final h = nodes[i].ltrb2.height;

      if (h < minvalue || h > maxValue) {
        nodes[i] = nodes[i].copyWith(hidden: true);
      }
    }
  }
  return nodes;
}
