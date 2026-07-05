class GLB {
  final bool valid;
  final String fileId;

  /// Axis-aligned bounding box of the geometry, in the glb's own coordinate
  /// space (metres). Kept as min/max rather than just a size so that the bounds
  /// of several glbs can be combined into a spatial union.
  final double minX;
  final double minY;
  final double minZ;
  final double maxX;
  final double maxY;
  final double maxZ;

  double get width => maxX - minX;
  double get height => maxY - minY;
  double get depth => maxZ - minZ;

  double get volume => width * height * depth;

  GLB({
    required this.fileId,
    required this.minX,
    required this.minY,
    required this.minZ,
    required this.maxX,
    required this.maxY,
    required this.maxZ,
  }) : valid = true;

  /// Convenience for a geometry of a given size positioned at the origin. Handy
  /// for tests and callers that only care about extents, not placement.
  GLB.sized({
    required this.fileId,
    required double width,
    required double height,
    required double depth,
  }) : minX = 0,
       minY = 0,
       minZ = 0,
       maxX = width,
       maxY = height,
       maxZ = depth,
       valid = true;

  GLB.invalid({required this.fileId})
    : minX = 0,
      minY = 0,
      minZ = 0,
      maxX = 0,
      maxY = 0,
      maxZ = 0,
      valid = false;
}
