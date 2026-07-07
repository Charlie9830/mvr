import 'dart:math' as math;

import 'package:mvr/src/classes/mvr_vector3.dart';

/// An axis-aligned bounding box in MVR world space.
///
/// All coordinates follow the MVR specification convention: right-handed,
/// Z-up, with 1 distance unit equal to 1 mm.
///
/// The box is axis-aligned to the *world* axes. When the source geometry is
/// rotated by its transform matrix, [length], [width] and [height] are the
/// extents of the enclosing world-aligned box, which are generally larger than
/// (and not equal to) the geometry's own physical dimensions.
class MVRBoundingBox {
  /// The minimum corner (smallest x, y, z) of the box.
  final MVRVector3 min;

  /// The maximum corner (largest x, y, z) of the box.
  final MVRVector3 max;

  const MVRBoundingBox({required this.min, required this.max});

  static const zero = MVRBoundingBox(min: MVRVector3.zero, max: MVRVector3.zero);

  /// Builds the world-aligned bounding box enclosing [points].
  ///
  /// Typically the eight (already transformed) corners of a piece of geometry.
  factory MVRBoundingBox.fromWorldPoints(Iterable<MVRVector3> points) {
    final iterator = points.iterator;
    if (!iterator.moveNext()) {
      return MVRBoundingBox.zero;
    }

    var minX = iterator.current.x;
    var minY = iterator.current.y;
    var minZ = iterator.current.z;
    var maxX = minX;
    var maxY = minY;
    var maxZ = minZ;

    while (iterator.moveNext()) {
      final p = iterator.current;
      minX = math.min(minX, p.x);
      minY = math.min(minY, p.y);
      minZ = math.min(minZ, p.z);
      maxX = math.max(maxX, p.x);
      maxY = math.max(maxY, p.y);
      maxZ = math.max(maxZ, p.z);
    }

    return MVRBoundingBox(
      min: MVRVector3(minX, minY, minZ),
      max: MVRVector3(maxX, maxY, maxZ),
    );
  }

  /// The eight corners of the box, in world space.
  List<MVRVector3> get corners => [
    MVRVector3(min.x, min.y, min.z),
    MVRVector3(max.x, min.y, min.z),
    MVRVector3(min.x, max.y, min.z),
    MVRVector3(max.x, max.y, min.z),
    MVRVector3(min.x, min.y, max.z),
    MVRVector3(max.x, min.y, max.z),
    MVRVector3(min.x, max.y, max.z),
    MVRVector3(max.x, max.y, max.z),
  ];

  /// The centre point of the box, in world space.
  MVRVector3 get center => (min + max) * 0.5;

  /// Extent along the world X axis (mm).
  double get length => max.x - min.x;

  /// Extent along the world Y axis (mm).
  double get width => max.y - min.y;

  /// Extent along the world Z (up) axis (mm).
  double get height => max.z - min.z;

  @override
  String toString() => 'MVRBoundingBox(min: $min, max: $max)';
}
