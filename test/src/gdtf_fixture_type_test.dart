import 'package:flutter_test/flutter_test.dart';
import 'package:mvr/errors/gdtf_errors.dart';
import 'package:mvr/src/classes/gdtf/gdtf_geometry.dart';
import 'package:mvr/src/classes/gdtf/gdtf_model.dart';
import 'package:mvr/src/gdtf/parse_gdtf_description.dart';

const _identity =
    '{1.000000,0.000000,0.000000,0.000000}'
    '{0.000000,1.000000,0.000000,0.000000}'
    '{0.000000,0.000000,1.000000,0.000000}'
    '{0,0,0,1}';

/// A simplified moving head: base, yoke hanging 0.2m below it, head 0.1m
/// below the yoke, beam 0.12m below the head.
const _movingHeadXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<GDTF DataVersion="1.2">
  <FixtureType Name="Test Head" ShortName="TH" LongName="Test Moving Head" Manufacturer="Acme" Description="A test fixture" FixtureTypeID="12345678-AAAA-BBBB-CCCC-1234567890AB" RefFT="">
    <Models>
      <Model Name="Base" Length="0.400000" Width="0.400000" Height="0.100000" PrimitiveType="Base1_1" File=""/>
      <Model Name="Yoke" Length="0.400000" Width="0.090000" Height="0.200000" PrimitiveType="Yoke" File=""/>
      <Model Name="Head" Length="0.250000" Width="0.250000" Height="0.240000" PrimitiveType="Head" File=""/>
      <Model Name="Beam" Length="0.040000" Width="0.040000" Height="0.010000" PrimitiveType="Cylinder" File=""/>
    </Models>
    <Geometries>
      <Geometry Name="Body" Position="$_identity">
        <Geometry Name="BasePart" Position="$_identity" Model="Base"/>
        <Axis Name="YokePart" Position="{1,0,0,0}{0,1,0,0}{0,0,1,-0.200000}{0,0,0,1}" Model="Yoke">
          <Axis Name="HeadPart" Position="{1,0,0,0}{0,1,0,0}{0,0,1,-0.100000}{0,0,0,1}" Model="Head">
            <Beam Name="BeamPart" Position="{1,0,0,0}{0,1,0,0}{0,0,1,-0.120000}{0,0,0,1}" Model="Beam"/>
          </Axis>
        </Axis>
      </Geometry>
    </Geometries>
    <DMXModes>
      <DMXMode Name="Mode 1" Description="" Geometry="Body"/>
    </DMXModes>
  </FixtureType>
</GDTF>
''';

/// A batten whose pixels are instanced with GeometryReference nodes. The
/// referenced 'Pixel' tree carries its own (bogus) 0.5m Z offset which must
/// be ignored when instanced: the reference's transform defines placement.
const _barXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<GDTF DataVersion="1.2">
  <FixtureType Name="Test Bar" ShortName="" LongName="" Manufacturer="Acme" Description="" FixtureTypeID="00000000-0000-0000-0000-000000000000" RefFT="">
    <Models>
      <Model Name="BarBody" Length="1.000000" Width="0.100000" Height="0.100000" PrimitiveType="Undefined" File="bar"/>
      <Model Name="Pixel" Length="0.050000" Width="0.050000" Height="0.010000" PrimitiveType="Cylinder" File=""/>
    </Models>
    <Geometries>
      <Geometry Name="Bar" Position="$_identity" Model="BarBody">
        <GeometryReference Name="Pixel 1" Position="{1,0,0,-0.475000}{0,1,0,0}{0,0,1,0}{0,0,0,1}" Geometry="Pixel"/>
        <GeometryReference Name="Pixel 2" Position="{1,0,0,0.475000}{0,1,0,0}{0,0,1,0}{0,0,0,1}" Geometry="Pixel"/>
      </Geometry>
      <Beam Name="Pixel" Position="{1,0,0,0}{0,1,0,0}{0,0,1,0.500000}{0,0,0,1}" Model="Pixel"/>
    </Geometries>
    <DMXModes>
      <DMXMode Name="Bar Mode" Description="" Geometry="Bar"/>
    </DMXModes>
  </FixtureType>
</GDTF>
''';

/// A single rotated slab, with no DMX modes: 0.4 x 0.1 x 0.05 m rotated 90
/// degrees about Z, so its world-aligned box swaps length and width.
const _rotatedSlabXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<GDTF DataVersion="1.1">
  <FixtureType Name="Slab" ShortName="" LongName="" Manufacturer="Acme" Description="" FixtureTypeID="00000000-0000-0000-0000-000000000001" RefFT="">
    <Models>
      <Model Name="Slab" Length="0.400000" Width="0.100000" Height="0.050000" PrimitiveType="Cube" File=""/>
    </Models>
    <Geometries>
      <Geometry Name="Root" Position="{0,-1,0,0}{1,0,0,0}{0,0,1,0}{0,0,0,1}" Model="Slab"/>
    </Geometries>
  </FixtureType>
</GDTF>
''';

/// Two top-level geometries referencing each other. Malformed per the spec,
/// but flattening must not recurse forever.
const _cyclicXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<GDTF DataVersion="1.2">
  <FixtureType Name="Cycle" ShortName="" LongName="" Manufacturer="" Description="" FixtureTypeID="00000000-0000-0000-0000-000000000002" RefFT="">
    <Models>
      <Model Name="Pixel" Length="0.050000" Width="0.050000" Height="0.010000" PrimitiveType="Cylinder" File=""/>
    </Models>
    <Geometries>
      <Geometry Name="A" Position="$_identity">
        <GeometryReference Name="refB" Position="$_identity" Geometry="B"/>
      </Geometry>
      <Geometry Name="B" Position="$_identity" Model="Pixel">
        <GeometryReference Name="refA" Position="$_identity" Geometry="A"/>
      </Geometry>
    </Geometries>
    <DMXModes>
      <DMXMode Name="Mode A" Description="" Geometry="A"/>
    </DMXModes>
  </FixtureType>
</GDTF>
''';

void main() {
  group('parseGdtfDescription metadata and models', () {
    test('Parses FixtureType attributes', () {
      final fixtureType = parseGdtfDescription(_movingHeadXml);

      expect(fixtureType.dataVersion, '1.2');
      expect(fixtureType.name, 'Test Head');
      expect(fixtureType.shortName, 'TH');
      expect(fixtureType.longName, 'Test Moving Head');
      expect(fixtureType.manufacturer, 'Acme');
      expect(fixtureType.description, 'A test fixture');
      expect(
        fixtureType.fixtureTypeId,
        '12345678-AAAA-BBBB-CCCC-1234567890AB',
      );
    });

    test('Parses models with dimensions converted from metres to mm', () {
      final fixtureType = parseGdtfDescription(_movingHeadXml);

      expect(fixtureType.models.length, 4);

      final base = fixtureType.models['Base']!;
      expect(base.length, closeTo(400, 1e-9));
      expect(base.width, closeTo(400, 1e-9));
      expect(base.height, closeTo(100, 1e-9));
      expect(base.primitiveType, GDTFPrimitiveType.base1_1);

      expect(
        fixtureType.models['Beam']!.primitiveType,
        GDTFPrimitiveType.cylinder,
      );
    });

    test('Parses the geometry tree with resolved models', () {
      final fixtureType = parseGdtfDescription(_movingHeadXml);

      expect(fixtureType.geometries.length, 1);

      final body = fixtureType.geometries.first;
      expect(body.type, GDTFGeometryType.geometry);
      expect(body.name, 'Body');
      expect(body.model, isNull);
      expect(body.children.length, 2);

      final yoke = body.children[1];
      expect(yoke.type, GDTFGeometryType.axis);
      expect(yoke.model, same(fixtureType.models['Yoke']));
      expect(yoke.position.z, closeTo(-200, 1e-9));

      final head = yoke.children.single;
      final beam = head.children.single;
      expect(beam.type, GDTFGeometryType.beam);
      expect(beam.modelName, 'Beam');
    });

    test('Parses DMX modes with their geometry binding', () {
      final fixtureType = parseGdtfDescription(_movingHeadXml);

      expect(fixtureType.dmxModes.length, 1);
      expect(fixtureType.dmxModes.first.name, 'Mode 1');
      expect(fixtureType.dmxModes.first.geometryName, 'Body');
      expect(fixtureType.dmxMode('Mode 1'), isNotNull);
      expect(fixtureType.dmxMode('Unknown'), isNull);
      expect(fixtureType.topLevelGeometry('Body'), isNotNull);
    });

    test('Throws MalformedGdtfDescriptionError for invalid input', () {
      expect(
        () => parseGdtfDescription('not xml at all'),
        throwsA(isA<MalformedGdtfDescriptionError>()),
      );
      expect(
        () => parseGdtfDescription('<NotGdtf/>'),
        throwsA(isA<MalformedGdtfDescriptionError>()),
      );
    });
  });

  group('Fixture type bounding box', () {
    test('Unions the transformed part boxes of a moving head', () {
      final fixtureType = parseGdtfDescription(_movingHeadXml);

      expect(fixtureType.parts.length, 4);

      // Base: z in [-50, 50]. Yoke at -200: [-300, -100]. Head at -300:
      // [-420, -180]. Beam at -420: [-425, -415].
      final box = fixtureType.boundingBox;
      expect(box.length, closeTo(400, 1e-6));
      expect(box.width, closeTo(400, 1e-6));
      expect(box.height, closeTo(475, 1e-6));
      expect(box.min.z, closeTo(-425, 1e-6));
      expect(box.max.z, closeTo(50, 1e-6));
    });

    test('boundingBoxForMode falls back to the default box', () {
      final fixtureType = parseGdtfDescription(_movingHeadXml);

      final forMode = fixtureType.boundingBoxForMode('Mode 1');
      final fallback = fixtureType.boundingBoxForMode('No Such Mode');

      expect(forMode.height, closeTo(475, 1e-6));
      expect(fallback.height, closeTo(475, 1e-6));
      expect(fixtureType.partsForMode('No Such Mode').length, 4);
    });

    test('Instantiates GeometryReference targets at the reference position', () {
      final fixtureType = parseGdtfDescription(_barXml);

      // BarBody plus two instanced pixels; the standalone 'Pixel' root is
      // not part of the mode's tree.
      final parts = fixtureType.partsForMode('Bar Mode');
      expect(parts.length, 3);

      final box = fixtureType.boundingBox;
      expect(box.length, closeTo(1000, 1e-6));
      expect(box.width, closeTo(100, 1e-6));

      // The referenced tree's own 0.5m Z offset must not leak into the
      // instances; the box stays the bar body's +/-50mm.
      expect(box.max.z, closeTo(50, 1e-6));
      expect(box.min.z, closeTo(-50, 1e-6));
    });

    test('A rotated part grows the box along the world axes', () {
      final fixtureType = parseGdtfDescription(_rotatedSlabXml);

      // No DMX modes: falls back to all top-level trees.
      expect(fixtureType.parts.length, 1);

      final box = fixtureType.boundingBox;
      expect(box.length, closeTo(100, 1e-6));
      expect(box.width, closeTo(400, 1e-6));
      expect(box.height, closeTo(50, 1e-6));
    });

    test('Reference cycles terminate instead of recursing forever', () {
      final fixtureType = parseGdtfDescription(_cyclicXml);

      final parts = fixtureType.partsForMode('Mode A');
      expect(parts.length, 1);
      expect(parts.single.model.name, 'Pixel');
    });
  });
}
