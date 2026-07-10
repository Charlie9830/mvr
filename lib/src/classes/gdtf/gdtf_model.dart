import 'package:collection/collection.dart';

/// The GDTF primitive used to visualise a model when no mesh file is used.
///
/// Values mirror the `PrimitiveType` attribute of the GDTF `Model` node.
enum GDTFPrimitiveType {
  undefined('Undefined'),
  cube('Cube'),
  cylinder('Cylinder'),
  sphere('Sphere'),
  base('Base'),
  yoke('Yoke'),
  head('Head'),
  scanner('Scanner'),
  conventional('Conventional'),
  pigtail('Pigtail'),
  base1_1('Base1_1'),
  scanner1_1('Scanner1_1'),
  conventional1_1('Conventional1_1');

  /// The attribute value as written in description.xml.
  final String xmlValue;

  const GDTFPrimitiveType(this.xmlValue);

  static GDTFPrimitiveType fromXmlValue(String? value) =>
      values.firstWhereOrNull((type) => type.xmlValue == value) ??
      GDTFPrimitiveType.undefined;
}

/// A GDTF `Model` node: the physical dimensions of one part of a fixture
/// (e.g. its base, yoke or head).
///
/// GDTF stores dimensions in metres; they are converted to mm here so all
/// geometry exposed by this package shares the MVR convention (right-handed,
/// Z-up, 1 unit = 1 mm).
class GDTFModel {
  final String name;

  /// Dimension of the model's bounding box along the X axis (mm).
  final double length;

  /// Dimension of the model's bounding box along the Y axis (mm).
  final double width;

  /// Dimension of the model's bounding box along the Z (up) axis (mm).
  final double height;

  final GDTFPrimitiveType primitiveType;

  /// File name (without extension) of the optional mesh file inside the GDTF
  /// archive. Empty when the model only uses a primitive. Mesh contents are
  /// not parsed by this package; [length]/[width]/[height] describe the
  /// bounding box either way.
  final String file;

  GDTFModel({
    required this.name,
    required this.length,
    required this.width,
    required this.height,
    this.primitiveType = GDTFPrimitiveType.undefined,
    this.file = '',
  });
}
