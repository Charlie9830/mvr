import 'package:collection/collection.dart';
import 'package:mvr/src/classes/gdtf/gdtf_dmx_mode.dart';
import 'package:mvr/src/classes/gdtf/gdtf_geometry.dart';
import 'package:mvr/src/classes/gdtf/gdtf_geometry_part.dart';
import 'package:mvr/src/classes/gdtf/gdtf_model.dart';
import 'package:mvr/src/classes/gdtf/gdtf_wiring_object.dart';
import 'package:mvr/src/classes/mvr_bounding_box.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/matrix.dart';

/// A GDTF fixture type, reduced to identity metadata and physical geometry.
///
/// This is the parsed form of a `.gdtf` file's description.xml, covering the
/// `FixtureType` attributes plus its `Models`, `Geometries` (including
/// `WiringObject` connections) and (geometry binding only) `DMXModes`
/// collects. Wheels, channels, physical descriptions and textures are out of
/// scope.
///
/// All geometry is expressed in MVR conventions — right-handed, Z-up,
/// 1 unit = 1 mm — in fixture-local space, with the origin at the centre of
/// the fixture's base. Combine with an `MVRFixture.matrix` to place a fixture
/// type's geometry in world space.
class GDTFFixtureType {
  /// The GDTF `DataVersion` of the file, e.g. '1.2'.
  final String dataVersion;

  final String name;
  final String shortName;
  final String longName;
  final String manufacturer;
  final String description;

  /// The unique fixture type ID (a GUID).
  final String fixtureTypeId;

  /// Name of the referenced fixture type, when this file is a revision of
  /// another one.
  final String refFT;

  /// The fixture type's models keyed by model name (mm dimensions).
  final Map<String, GDTFModel> models;

  /// The top-level geometry trees of the `Geometries` collect.
  final List<GDTFGeometry> geometries;

  /// The fixture type's DMX modes (name and geometry binding only).
  final List<GDTFDmxMode> dmxModes;

  /// The fixture's physical parts with accumulated fixture-local transforms.
  ///
  /// Flattened from the default geometry tree: the tree bound to the first
  /// DMX mode, falling back to every top-level tree when no mode resolves.
  /// Use [partsForMode] when the fixture's `GDTFMode` is known.
  final List<GDTFGeometryPart> parts;

  /// The fixture-local, axis-aligned bounding box enclosing [parts] (mm,
  /// Z-up, origin at the centre of the fixture's base).
  ///
  /// Zero when the fixture type contains no usable geometry.
  final MVRBoundingBox boundingBox;

  /// The fixture's wiring objects (power, data and network connections) with
  /// accumulated fixture-local transforms.
  ///
  /// Flattened from the same default geometry tree as [parts]. Use
  /// [wiringObjectsForMode] when the fixture's `GDTFMode` is known.
  final List<GDTFWiringObjectInstance> wiringObjects;

  final Map<String, GDTFGeometry> _topLevelGeometryByName;
  final Map<String, List<GDTFGeometryPart>> _partsByRootName;
  final Map<String, MVRBoundingBox> _boundsByRootName;
  final Map<String, List<GDTFWiringObjectInstance>> _wiringObjectsByRootName;
  final Map<String, GDTFWiringObject> _wiringObjectByName;

  GDTFFixtureType._({
    required this.dataVersion,
    required this.name,
    required this.shortName,
    required this.longName,
    required this.manufacturer,
    required this.description,
    required this.fixtureTypeId,
    required this.refFT,
    required this.models,
    required this.geometries,
    required this.dmxModes,
    required this.parts,
    required this.boundingBox,
    required this.wiringObjects,
    required Map<String, GDTFGeometry> topLevelGeometryByName,
    required Map<String, List<GDTFGeometryPart>> partsByRootName,
    required Map<String, MVRBoundingBox> boundsByRootName,
    required Map<String, List<GDTFWiringObjectInstance>>
    wiringObjectsByRootName,
    required Map<String, GDTFWiringObject> wiringObjectByName,
  }) : _topLevelGeometryByName = topLevelGeometryByName,
       _partsByRootName = partsByRootName,
       _boundsByRootName = boundsByRootName,
       _wiringObjectsByRootName = wiringObjectsByRootName,
       _wiringObjectByName = wiringObjectByName;

  factory GDTFFixtureType({
    String dataVersion = '',
    String name = '',
    String shortName = '',
    String longName = '',
    String manufacturer = '',
    String description = '',
    String fixtureTypeId = '',
    String refFT = '',
    Map<String, GDTFModel> models = const {},
    List<GDTFGeometry> geometries = const [],
    List<GDTFDmxMode> dmxModes = const [],
  }) {
    final topLevelByName = {
      for (final geometry in geometries) geometry.name: geometry,
    };

    final flattenedByRootName = {
      for (final geometry in geometries)
        geometry.name: _flatten(geometry, topLevelByName),
    };

    final partsByRootName = flattenedByRootName.map(
      (name, flattened) => MapEntry(name, flattened.parts),
    );

    final wiringObjectsByRootName = flattenedByRootName.map(
      (name, flattened) => MapEntry(name, flattened.wiringObjects),
    );

    final boundsByRootName = partsByRootName.map(
      (name, parts) => MapEntry(name, _boundsOf(parts)),
    );

    // The default geometry: the tree bound to the first DMX mode that
    // resolves. When no mode resolves (or none exist), fall back to every
    // top-level tree so files without modes still report their geometry.
    final defaultRootName = dmxModes
        .map((mode) => mode.geometryName)
        .firstWhereOrNull(flattenedByRootName.containsKey);

    final parts =
        partsByRootName[defaultRootName] ??
        partsByRootName.values.flattened.toList();

    final wiringObjects =
        wiringObjectsByRootName[defaultRootName] ??
        wiringObjectsByRootName.values.flattened.toList();

    return GDTFFixtureType._(
      dataVersion: dataVersion,
      name: name,
      shortName: shortName,
      longName: longName,
      manufacturer: manufacturer,
      description: description,
      fixtureTypeId: fixtureTypeId,
      refFT: refFT,
      models: models,
      geometries: geometries,
      dmxModes: dmxModes,
      parts: parts,
      boundingBox: _boundsOf(parts),
      wiringObjects: wiringObjects,
      topLevelGeometryByName: topLevelByName,
      partsByRootName: partsByRootName,
      boundsByRootName: boundsByRootName,
      wiringObjectsByRootName: wiringObjectsByRootName,
      wiringObjectByName: {
        for (final wiringObject in geometries.expand(_wiringObjectsIn))
          wiringObject.name: wiringObject,
      },
    );
  }

  /// Looks up a top-level geometry tree by name, as referenced by
  /// [GDTFDmxMode.geometryName] and [GDTFGeometry.referencedGeometryName].
  GDTFGeometry? topLevelGeometry(String name) => _topLevelGeometryByName[name];

  /// The DMX mode named [gdtfMode] (the value carried by an MVR `Fixture`'s
  /// `GDTFMode` node), or null when unknown.
  GDTFDmxMode? dmxMode(String gdtfMode) =>
      dmxModes.firstWhereOrNull((mode) => mode.name == gdtfMode);

  /// The fixture's parts when patched in [gdtfMode].
  ///
  /// Falls back to the default [parts] when the mode or its geometry cannot
  /// be resolved, so callers can pass `MVRFixture.gdtfMode` through without
  /// checking it first.
  List<GDTFGeometryPart> partsForMode(String gdtfMode) {
    final geometryName = dmxMode(gdtfMode)?.geometryName;
    return _partsByRootName[geometryName] ?? parts;
  }

  /// The fixture-local bounding box when patched in [gdtfMode].
  ///
  /// Falls back to the default [boundingBox] when the mode or its geometry
  /// cannot be resolved.
  MVRBoundingBox boundingBoxForMode(String gdtfMode) {
    final geometryName = dmxMode(gdtfMode)?.geometryName;
    return _boundsByRootName[geometryName] ?? boundingBox;
  }

  /// The fixture's wiring objects when patched in [gdtfMode].
  ///
  /// Falls back to the default [wiringObjects] when the mode or its geometry
  /// cannot be resolved.
  List<GDTFWiringObjectInstance> wiringObjectsForMode(String gdtfMode) {
    final geometryName = dmxMode(gdtfMode)?.geometryName;
    return _wiringObjectsByRootName[geometryName] ?? wiringObjects;
  }

  /// Looks up a wiring object anywhere in the `Geometries` collect by name,
  /// as referenced by [GDTFPinPatch.toWiringObjectName].
  GDTFWiringObject? wiringObjectByName(String name) =>
      _wiringObjectByName[name];

  /// Every wiring object node in the tree rooted at [node], without following
  /// `GeometryReference` nodes.
  static Iterable<GDTFWiringObject> _wiringObjectsIn(GDTFGeometry node) => [
    if (node is GDTFWiringObject) node,
    ...node.children.expand(_wiringObjectsIn),
  ];

  /// Flattens the tree rooted at [root] into parts and wiring objects with
  /// accumulated fixture-local transforms, following `GeometryReference`
  /// nodes.
  ///
  /// A referenced tree is instantiated at the *reference's* transform (its
  /// own top-level position is ignored, per the GDTF spec the reference
  /// defines where the instance sits). [activeRefs] guards against reference
  /// cycles in malformed files.
  static ({
    List<GDTFGeometryPart> parts,
    List<GDTFWiringObjectInstance> wiringObjects,
  })
  _flatten(GDTFGeometry root, Map<String, GDTFGeometry> topLevelByName) {
    final parts = <GDTFGeometryPart>[];
    final wiringObjects = <GDTFWiringObjectInstance>[];

    void walk(
      GDTFGeometry node,
      MVRMatrix nodeTransform,
      Set<String> activeRefs,
    ) {
      if (node is GDTFWiringObject) {
        wiringObjects.add(
          GDTFWiringObjectInstance(
            wiringObject: node,
            transform: nodeTransform,
          ),
        );
      }

      final model = node.model;
      if (model != null) {
        parts.add(
          GDTFGeometryPart(
            geometry: node,
            model: model,
            transform: nodeTransform,
          ),
        );
      }

      for (final child in node.children) {
        walk(child, nodeTransform.multiply(child.position), activeRefs);
      }

      if (node.type == GDTFGeometryType.geometryReference) {
        final target = topLevelByName[node.referencedGeometryName];
        if (target != null && !activeRefs.contains(target.name)) {
          walk(target, nodeTransform, {...activeRefs, target.name});
        }
      }
    }

    walk(root, root.position, {root.name});
    return (parts: parts, wiringObjects: wiringObjects);
  }

  static MVRBoundingBox _boundsOf(List<GDTFGeometryPart> parts) {
    if (parts.isEmpty) {
      return MVRBoundingBox.zero;
    }

    return MVRBoundingBox.fromWorldPoints(parts.expand((part) => part.corners));
  }
}
