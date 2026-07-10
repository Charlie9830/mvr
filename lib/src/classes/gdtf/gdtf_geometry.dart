import 'package:collection/collection.dart';
import 'package:mvr/src/classes/gdtf/gdtf_model.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/matrix.dart';

/// The kind of a node in a GDTF geometry tree.
///
/// Values mirror the element tag names allowed inside the GDTF `Geometries`
/// collect.
enum GDTFGeometryType {
  geometry('Geometry'),
  axis('Axis'),
  filterBeam('FilterBeam'),
  filterColor('FilterColor'),
  filterGobo('FilterGobo'),
  filterShaper('FilterShaper'),
  beam('Beam'),
  mediaServerLayer('MediaServerLayer'),
  mediaServerCamera('MediaServerCamera'),
  mediaServerMaster('MediaServerMaster'),
  display('Display'),
  geometryReference('GeometryReference'),
  laser('Laser'),
  wiringObject('WiringObject'),
  inventory('Inventory'),
  structure('Structure'),
  support('Support'),
  magnet('Magnet');

  /// The element tag name as written in description.xml.
  final String tagName;

  const GDTFGeometryType(this.tagName);

  static GDTFGeometryType? fromTagName(String tagName) =>
      values.firstWhereOrNull((type) => type.tagName == tagName);
}

/// A node in a GDTF fixture type's geometry tree.
///
/// Each node carries a transform ([position]) relative to its parent and may
/// reference a [model] describing the physical dimensions of the part it
/// represents. Grouping nodes (and e.g. axes without their own housing) have
/// no model.
class GDTFGeometry {
  final GDTFGeometryType type;
  final String name;

  /// The name of the referenced `Model` node, or an empty string when the
  /// geometry has no model.
  final String modelName;

  /// The resolved model for [modelName], or null when the geometry has no
  /// model or the reference is dangling.
  final GDTFModel? model;

  /// The transform of this node relative to its parent.
  ///
  /// GDTF matrices are converted to the MVR matrix convention on parse:
  /// basis vectors in rows 0-2, translation in row 3, translation in mm
  /// (GDTF stores metres), right-handed, Z-up.
  final MVRMatrix position;

  /// For [GDTFGeometryType.geometryReference] nodes: the name of the
  /// referenced top-level geometry. Empty otherwise. Resolve it via
  /// `GDTFFixtureType.topLevelGeometry`.
  final String referencedGeometryName;

  final List<GDTFGeometry> children;

  GDTFGeometry({
    required this.type,
    required this.name,
    this.modelName = '',
    this.model,
    this.position = const MVRMatrix.identity(),
    this.referencedGeometryName = '',
    this.children = const [],
  });
}
