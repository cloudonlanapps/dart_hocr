// ignore_for_file: public_member_api_docs, sort_constructors_first
class Box {
  final double l;
  final double t;
  final double r;
  final double b;
  Box({required this.l, required this.t, required this.r, required this.b});
  factory Box.fromltrb(List<double> ltrb) {
    return Box(l: ltrb[0], t: ltrb[1], r: ltrb[2], b: ltrb[3]);
  }

  bool isOutside(Box other) {
    if ((t > other.b) | (b < other.t)) {
      return true;
    }
    if ((l > other.r) || (r < other.l)) {
      return true;
    }
    return false;
  }

  bool isInside(Box other) {
    return ((t > other.b) && (b < other.t) && (l > other.r) && (r < other.l));
  }

  bool isPointInside(double x, double y) {
    return (y > t && y < b) && (x > l && x < r);
  }

  bool isOverlap(Box other) {
    final ov1 = other.isPointInside(l, t) ||
        other.isPointInside(l, b) ||
        other.isPointInside(r, t) ||
        other.isPointInside(r, b);
    final ov2 = isPointInside(other.l, other.t) ||
        isPointInside(other.l, other.b) ||
        isPointInside(other.r, other.t) ||
        isPointInside(other.r, other.b);
    return ov1 || ov2;
  }

  @override
  String toString() => 'Box(l: $l, t: $t, r: $r, b: $b)';

  List<double> get ltrb => [l, t, r, b];

  @override
  bool operator ==(covariant Box other) {
    if (identical(this, other)) return true;

    return other.b == b;
  }

  double get height => b - t;
  double get width => r - l;

  @override
  int get hashCode => b.hashCode;

  Box copyWith({
    double? l,
    double? t,
    double? r,
    double? b,
  }) {
    return Box(
      l: l ?? this.l,
      t: t ?? this.t,
      r: r ?? this.r,
      b: b ?? this.b,
    );
  }
}
