import 'package:collection/collection.dart';
import 'package:mvr/src/classes/gdtf/gdtf_connector_type.dart';
import 'package:mvr/src/classes/gdtf/gdtf_geometry.dart';
import 'package:mvr/src/classes/gdtf/gdtf_signal_type.dart';
import 'package:mvr/src/classes/mvr_vector3.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/matrix.dart';

/// The electrical role of a GDTF `WiringObject`.
///
/// Values mirror the `ComponentType` attribute.
enum GDTFComponentType {
  input('Input'),
  output('Output'),
  powerSource('PowerSource'),
  consumer('Consumer'),
  fuse('Fuse'),
  networkProvider('NetworkProvider'),
  networkInput('NetworkInput'),
  networkOutput('NetworkOutput'),
  networkInOut('NetworkInOut');

  /// The attribute value as written in description.xml.
  final String xmlValue;

  const GDTFComponentType(this.xmlValue);

  static GDTFComponentType? fromXmlValue(String? value) =>
      values.firstWhereOrNull((type) => type.xmlValue == value);
}

/// The trip characteristic of a fuse `WiringObject`.
///
/// Values mirror the `FuseRating` attribute.
enum GDTFFuseRating {
  b('B'),
  c('C'),
  d('D'),
  k('K'),
  z('Z');

  /// The attribute value as written in description.xml.
  final String xmlValue;

  const GDTFFuseRating(this.xmlValue);

  static GDTFFuseRating? fromXmlValue(String? value) =>
      values.firstWhereOrNull((rating) => rating.xmlValue == value);
}

/// Where the pins of a `WiringObject` are placed on the object.
///
/// Values mirror the `Orientation` attribute.
enum GDTFWiringOrientation {
  left('Left'),
  right('Right'),
  top('Top'),
  bottom('Bottom');

  /// The attribute value as written in description.xml.
  final String xmlValue;

  const GDTFWiringOrientation(this.xmlValue);

  static GDTFWiringOrientation? fromXmlValue(String? value) =>
      values.firstWhereOrNull((orientation) => orientation.xmlValue == value);
}

/// A GDTF `PinPatch` node: how one pin of its parent wiring object is wired
/// to a pin of another wiring object.
class GDTFPinPatch {
  /// The name of the wiring object this patch connects to. Resolve it via
  /// `GDTFFixtureType.wiringObjectByName`.
  final String toWiringObjectName;

  /// The pin number on the parent wiring object.
  final int fromPin;

  /// The pin number on the [toWiringObjectName] wiring object.
  final int toPin;

  GDTFPinPatch({
    required this.toWiringObjectName,
    required this.fromPin,
    required this.toPin,
  });
}

/// A GDTF `WiringObject` geometry: an electrical connection point of a
/// fixture, such as a power input, DMX thru or network port.
///
/// Wiring objects are ordinary nodes of the geometry tree (their [type] is
/// always [GDTFGeometryType.wiringObject]), so they carry a [position] and
/// children like any other geometry. Use `GDTFFixtureType.wiringObjects` for
/// a flattened list with fixture-local transforms.
///
/// Electrical values are exposed in the units GDTF defines (W, V, Hz, VA,
/// A). Many attributes only apply to certain [componentType]s and fixture
/// files commonly write 0 for the rest; they default to 0 when absent.
class GDTFWiringObject extends GDTFGeometry {
  /// The connector type, or null when not specified (e.g. for fuses).
  final GDTFConnectorType? connectorType;

  /// The electrical role of the object, or null when absent or unrecognised.
  final GDTFComponentType? componentType;

  /// The signal carried, or null when not specified.
  final GDTFSignalType? signalType;

  /// The number of pins available to connect internal wiring to.
  final int pinCount;

  /// Electrical consumption in watts. Consumers only.
  final double electricalPayLoad;

  /// Maximum of the accepted voltage range in volts. Consumers only.
  final double voltageRangeMax;

  /// Minimum of the accepted voltage range in volts. Consumers only.
  final double voltageRangeMin;

  /// Maximum of the accepted frequency range in hertz. Consumers only.
  final double frequencyRangeMax;

  /// Minimum of the accepted frequency range in hertz. Consumers only.
  final double frequencyRangeMin;

  /// Maximum payload this power source can handle in volt-amperes. Power
  /// sources only.
  final double maxPayLoad;

  /// Output voltage in volts. Power sources only.
  final double voltage;

  /// The signal layer. Within one fixture, all wiring objects sharing a
  /// signal layer are connected; 0 means connected to all geometries. Null
  /// when absent, so it is not mistaken for that special value.
  final int? signalLayer;

  /// The power factor. Consumers only.
  final double cosPhi;

  /// The fuse value in amperes. Fuses only.
  final double fuseCurrent;

  /// The fuse rating, or null when absent or unrecognised.
  final GDTFFuseRating? fuseRating;

  /// Where the pins are placed on the object, or null when absent or
  /// unrecognised.
  final GDTFWiringOrientation? orientation;

  /// Name of the group this wiring object belongs to, or empty.
  final String wireGroup;

  /// How this object's pins are wired to other wiring objects.
  final List<GDTFPinPatch> pinPatches;

  GDTFWiringObject({
    required super.name,
    super.modelName,
    super.model,
    super.position,
    super.children,
    this.connectorType,
    this.componentType,
    this.signalType,
    this.pinCount = 0,
    this.electricalPayLoad = 0,
    this.voltageRangeMax = 0,
    this.voltageRangeMin = 0,
    this.frequencyRangeMax = 0,
    this.frequencyRangeMin = 0,
    this.maxPayLoad = 0,
    this.voltage = 0,
    this.signalLayer,
    this.cosPhi = 0,
    this.fuseCurrent = 0,
    this.fuseRating,
    this.orientation,
    this.wireGroup = '',
    this.pinPatches = const [],
  }) : super(type: GDTFGeometryType.wiringObject);
}

/// A wiring object placed in fixture-local space.
///
/// The wiring equivalent of `GDTFGeometryPart`: pairs a [wiringObject] with
/// its accumulated [transform] from the geometry tree root, with
/// `GeometryReference` nodes resolved (so a wiring object inside a referenced
/// geometry yields one instance per reference). Coordinates follow the MVR
/// convention: right-handed, Z-up, mm.
class GDTFWiringObjectInstance {
  final GDTFWiringObject wiringObject;

  /// The wiring object's transform in fixture-local space (translation in
  /// mm).
  final MVRMatrix transform;

  GDTFWiringObjectInstance({
    required this.wiringObject,
    required this.transform,
  });

  /// The wiring object's origin in fixture-local space (mm).
  MVRVector3 get location => MVRVector3(transform.x, transform.y, transform.z);
}
