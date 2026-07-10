import 'package:mvr/errors/gdtf_errors.dart';
import 'package:mvr/src/classes/gdtf/gdtf_dmx_mode.dart';
import 'package:mvr/src/classes/gdtf/gdtf_geometry.dart';
import 'package:mvr/src/classes/gdtf/gdtf_fixture_type.dart';
import 'package:mvr/src/classes/gdtf/gdtf_model.dart';
import 'package:mvr/src/gdtf/gdtf_matrix.dart';
import 'package:xml/xml.dart';

/// Parses the contents of a GDTF description.xml document into a
/// [GDTFFixtureType].
///
/// Throws [MalformedGdtfDescriptionError] when [contents] is not valid XML or
/// does not contain a `GDTF > FixtureType` structure.
GDTFFixtureType parseGdtfDescription(String contents) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(contents);
  } on XmlException {
    throw MalformedGdtfDescriptionError();
  }

  final root = document.rootElement;
  final fixtureTypeElement = root.getElement('FixtureType');

  if (root.name.local != 'GDTF' || fixtureTypeElement == null) {
    throw MalformedGdtfDescriptionError();
  }

  final models = _parseModels(fixtureTypeElement.getElement('Models'));

  return GDTFFixtureType(
    dataVersion: root.getAttribute('DataVersion') ?? '',
    name: fixtureTypeElement.getAttribute('Name') ?? '',
    shortName: fixtureTypeElement.getAttribute('ShortName') ?? '',
    longName: fixtureTypeElement.getAttribute('LongName') ?? '',
    manufacturer: fixtureTypeElement.getAttribute('Manufacturer') ?? '',
    description: fixtureTypeElement.getAttribute('Description') ?? '',
    fixtureTypeId: fixtureTypeElement.getAttribute('FixtureTypeID') ?? '',
    refFT: fixtureTypeElement.getAttribute('RefFT') ?? '',
    models: models,
    geometries: _parseGeometryChildren(
      fixtureTypeElement.getElement('Geometries'),
      models,
    ),
    dmxModes: _parseDmxModes(fixtureTypeElement.getElement('DMXModes')),
  );
}

Map<String, GDTFModel> _parseModels(XmlElement? modelsElement) {
  if (modelsElement == null) {
    return const {};
  }

  // GDTF dimensions are metres; the package exposes mm throughout.
  double millimetres(String? value) =>
      (double.tryParse(value ?? '') ?? 0) * 1000;

  return {
    for (final element in modelsElement.findElements('Model'))
      (element.getAttribute('Name') ?? ''): GDTFModel(
        name: element.getAttribute('Name') ?? '',
        length: millimetres(element.getAttribute('Length')),
        width: millimetres(element.getAttribute('Width')),
        height: millimetres(element.getAttribute('Height')),
        primitiveType: GDTFPrimitiveType.fromXmlValue(
          element.getAttribute('PrimitiveType'),
        ),
        file: element.getAttribute('File') ?? '',
      ),
  };
}

List<GDTFGeometry> _parseGeometryChildren(
  XmlElement? parent,
  Map<String, GDTFModel> models,
) {
  if (parent == null) {
    return const [];
  }

  return parent.childElements
      .map((element) {
        final type = GDTFGeometryType.fromTagName(element.name.local);

        if (type == null) {
          return null;
        }

        final modelName = element.getAttribute('Model') ?? '';

        return GDTFGeometry(
          type: type,
          name: element.getAttribute('Name') ?? '',
          modelName: modelName,
          model: models[modelName],
          position: parseGdtfMatrix(element.getAttribute('Position')),
          referencedGeometryName: element.getAttribute('Geometry') ?? '',
          children: _parseGeometryChildren(element, models),
        );
      })
      .nonNulls
      .toList();
}

List<GDTFDmxMode> _parseDmxModes(XmlElement? dmxModesElement) {
  if (dmxModesElement == null) {
    return const [];
  }

  return dmxModesElement
      .findElements('DMXMode')
      .map(
        (element) => GDTFDmxMode(
          name: element.getAttribute('Name') ?? '',
          description: element.getAttribute('Description') ?? '',
          geometryName: element.getAttribute('Geometry') ?? '',
        ),
      )
      .toList();
}
