class GLB {
  final bool valid;
  final String fileId;
  final double width;
  final double height;
  final double depth;

  double get volume => width * height * depth;

  GLB({
    required this.fileId,
    required this.width,
    required this.height,
    required this.depth,
  }) : valid = true;

  GLB.invalid({required this.fileId})
    : width = 0,
      height = 0,
      depth = 0,
      valid = false;
}
