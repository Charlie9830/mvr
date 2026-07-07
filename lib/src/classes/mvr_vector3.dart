/// A point or vector in MVR world space.
///
/// Follows the MVR specification convention: right-handed, Z-up, with 1
/// distance unit equal to 1 mm.
class MVRVector3 {
  final double x;
  final double y;
  final double z;

  const MVRVector3(this.x, this.y, this.z);

  static const zero = MVRVector3(0, 0, 0);

  MVRVector3 operator +(MVRVector3 other) =>
      MVRVector3(x + other.x, y + other.y, z + other.z);

  MVRVector3 operator -(MVRVector3 other) =>
      MVRVector3(x - other.x, y - other.y, z - other.z);

  MVRVector3 operator *(double scalar) =>
      MVRVector3(x * scalar, y * scalar, z * scalar);

  @override
  bool operator ==(Object other) =>
      other is MVRVector3 && other.x == x && other.y == y && other.z == z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => 'MVRVector3($x, $y, $z)';
}
