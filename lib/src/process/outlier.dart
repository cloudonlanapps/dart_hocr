/// Outlier algo, WIP.
///               |
///               |
///            ---|---   <- q1 75% index          ---
///            |     |
///            |     |
///            -------  < q2 50% index (median)  ` gap: in value`
///            |     |
///            |     |
///            ---|---  < q3 25% index            ---
///               |
///               |
///
/// Known Issues:Use with caution!
///   if the list.length is too small, the behaviour may be undesirable.
///
class OutlierRange {
  late final double low;
  late final double high;

  OutlierRange(List<double> list) {
    if (list.isEmpty) {
      throw Exception("Empty list is provided.");
    }
    final sortedList = List.from(list);
    sortedList.sort((a, b) => a.compareTo(b));

    final q1 =
        min(list.length - 1, (list.length * 0.25).floorToDouble()).toInt();
    final q2 =
        min(list.length - 1, (list.length * 0.5).roundToDouble()).toInt();
    final q3 =
        min(list.length - 1, (list.length * 0.75).roundToDouble()).toInt();

    final gap = sortedList[q3] - sortedList[q1];

    low = sortedList[q2] - 1.5 * gap;
    high = sortedList[q2] + 1.5 * gap;
  }
  double min(double a, double b) {
    return (a < b) ? a : b;
  }
}
