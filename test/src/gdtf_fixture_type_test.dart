import 'package:flutter_test/flutter_test.dart';
import 'package:mvr/errors/gdtf_errors.dart';
import 'package:mvr/src/classes/gdtf/gdtf_geometry.dart';
import 'package:mvr/src/classes/gdtf/gdtf_connector_type.dart';
import 'package:mvr/src/classes/gdtf/gdtf_model.dart';
import 'package:mvr/src/classes/gdtf/gdtf_signal_type.dart';
import 'package:mvr/src/classes/gdtf/gdtf_wiring_object.dart';
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

/// A dimmer with a power inlet and thru on a 0.1m-offset connector panel, a
/// fuse wired to the inlet, and DMX ports instanced per GeometryReference.
/// The 'Port' tree's own 1m offset must be ignored when instanced.
const _wiringXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<GDTF DataVersion="1.2">
  <FixtureType Name="Wired" ShortName="" LongName="" Manufacturer="Acme" Description="" FixtureTypeID="00000000-0000-0000-0000-000000000003" RefFT="">
    <Models>
      <Model Name="Body" Length="0.300000" Width="0.200000" Height="0.100000" PrimitiveType="Cube" File=""/>
    </Models>
    <Geometries>
      <Geometry Name="Base" Position="$_identity" Model="Body">
        <Geometry Name="Panel" Position="{1,0,0,0.100000}{0,1,0,0}{0,0,1,0}{0,0,0,1}">
          <WiringObject Name="Power IN" Position="$_identity" ComponentType="Consumer" ConnectorType="powerCONTRUE1TOP" SignalType="Power" PinCount="3" SignalLayer="1" Orientation="Left" WireGroup="Mains" ElectricalPayLoad="285.000000" VoltageRangeMin="100.000000" VoltageRangeMax="240.000000" FrequencyRangeMin="50.000000" FrequencyRangeMax="60.000000" CosPhi="0.990000" MaxPayLoad="0.000000" Voltage="0.000000" FuseCurrent="0.000000">
            <PinPatch ToWiringObject="Fuse" FromPin="1" ToPin="2"/>
          </WiringObject>
          <WiringObject Name="Power THRU" Position="{1,0,0,0}{0,1,0,0.050000}{0,0,1,0}{0,0,0,1}" ComponentType="PowerSource" ConnectorType="xlr3" SignalType="Power" PinCount="3" MaxPayLoad="2300.000000" Voltage="230.000000"/>
          <WiringObject Name="Fuse" Position="$_identity" ComponentType="Fuse" FuseCurrent="10.000000" FuseRating="C"/>
          <WiringObject Name="Ethernet" Position="$_identity" ComponentType="NetworkInOut" ConnectorType="etherCON" SignalType="Ethernet" PinCount="8"/>
        </Geometry>
        <GeometryReference Name="Port 1" Position="{1,0,0,-0.100000}{0,1,0,0}{0,0,1,0}{0,0,0,1}" Geometry="Port"/>
        <GeometryReference Name="Port 2" Position="{1,0,0,-0.050000}{0,1,0,0}{0,0,1,0}{0,0,0,1}" Geometry="Port"/>
      </Geometry>
      <Geometry Name="Port" Position="{1,0,0,0}{0,1,0,0}{0,0,1,1.000000}{0,0,0,1}">
        <WiringObject Name="DMX" Position="$_identity" ComponentType="Input" ConnectorType="XLR5" SignalType="DMX512" PinCount="5" SignalLayer="0"/>
      </Geometry>
    </Geometries>
    <DMXModes>
      <DMXMode Name="Mode" Description="" Geometry="Base"/>
      <DMXMode Name="Port Only" Description="" Geometry="Port"/>
    </DMXModes>
  </FixtureType>
</GDTF>
''';

/// Exercises exhaustive switching: this must keep compiling without a
/// default case for every predefined connector type plus custom ones.
String _describeConnector(GDTFConnectorType? type) => switch (type) {
  GDTFPredefinedConnectorType.xlr5 => 'DMX',
  GDTFPredefinedConnectorType(:final description) => description,
  GDTFCustomConnectorType(:final xmlValue) => 'Custom $xmlValue',
  null => 'None',
};

void main() {
  group('Connector and signal types', () {
    test('Predefined connector types resolve to their enum value', () {
      expect(
        GDTFConnectorType.fromXmlValue('XLR5'),
        GDTFPredefinedConnectorType.xlr5,
      );
      expect(
        GDTFConnectorType.fromXmlValue('IEC 60320-C13/14'),
        GDTFPredefinedConnectorType.iec60320C13C14,
      );
      expect(
        GDTFConnectorType.fromXmlValue('N_CON'),
        GDTFPredefinedConnectorType.nCon,
      );
    });

    test('Predefined matching ignores case and surrounding whitespace', () {
      expect(
        GDTFConnectorType.fromXmlValue(' rj45 '),
        GDTFPredefinedConnectorType.rj45,
      );
      expect(
        GDTFConnectorType.fromXmlValue('PowerconTrue1Top'),
        GDTFPredefinedConnectorType.powerconTrue1Top,
      );
    });

    test('Every Annex D value round trips and is unique ignoring case', () {
      final normalised = {
        for (final type in GDTFPredefinedConnectorType.values)
          type.xmlValue.toLowerCase(),
      };
      expect(normalised.length, GDTFPredefinedConnectorType.values.length);
      // Table D.1 lists 84 connector types.
      expect(GDTFPredefinedConnectorType.values.length, 84);

      for (final type in GDTFPredefinedConnectorType.values) {
        expect(GDTFConnectorType.fromXmlValue(type.xmlValue), type);
      }
    });

    test('Unknown values become custom types with value equality', () {
      final type = GDTFConnectorType.fromXmlValue('Loose End');

      expect(type, isA<GDTFCustomConnectorType>());
      expect(type, const GDTFCustomConnectorType('Loose End'));
      expect(type!.xmlValue, 'Loose End');
      expect(_describeConnector(type), 'Custom Loose End');
      expect(_describeConnector(GDTFPredefinedConnectorType.xlr5), 'DMX');
      expect(_describeConnector(GDTFPredefinedConnectorType.nl4), 'Speakon');
    });

    test('Blank values parse to null', () {
      expect(GDTFConnectorType.fromXmlValue(null), isNull);
      expect(GDTFConnectorType.fromXmlValue('  '), isNull);
      expect(GDTFSignalType.fromXmlValue(''), isNull);
    });

    test('Signal types distinguish predefined and custom values', () {
      expect(
        GDTFSignalType.fromXmlValue('DMX512'),
        GDTFPredefinedSignalType.dmx512,
      );
      expect(
        GDTFSignalType.fromXmlValue('Ethernet'),
        const GDTFCustomSignalType('Ethernet'),
      );
    });
  });

  group('WiringObject parsing', () {
    test('Parses wiring object attributes into a GDTFWiringObject', () {
      final fixtureType = parseGdtfDescription(_wiringXml);

      final powerIn = fixtureType.wiringObjectByName('Power IN')!;
      expect(powerIn.type, GDTFGeometryType.wiringObject);
      expect(
        powerIn.connectorType,
        GDTFPredefinedConnectorType.powerconTrue1Top,
      );
      expect(powerIn.componentType, GDTFComponentType.consumer);
      expect(powerIn.signalType, GDTFPredefinedSignalType.power);
      expect(powerIn.pinCount, 3);
      expect(powerIn.signalLayer, 1);
      expect(powerIn.orientation, GDTFWiringOrientation.left);
      expect(powerIn.wireGroup, 'Mains');
      expect(powerIn.electricalPayLoad, closeTo(285, 1e-9));
      expect(powerIn.voltageRangeMin, closeTo(100, 1e-9));
      expect(powerIn.voltageRangeMax, closeTo(240, 1e-9));
      expect(powerIn.frequencyRangeMin, closeTo(50, 1e-9));
      expect(powerIn.frequencyRangeMax, closeTo(60, 1e-9));
      expect(powerIn.cosPhi, closeTo(0.99, 1e-9));

      final thru = fixtureType.wiringObjectByName('Power THRU')!;
      expect(thru.componentType, GDTFComponentType.powerSource);
      expect(thru.connectorType, GDTFPredefinedConnectorType.xlr3);
      expect(thru.maxPayLoad, closeTo(2300, 1e-9));
      expect(thru.voltage, closeTo(230, 1e-9));
    });

    test('Absent attributes use defaults without inventing values', () {
      final fixtureType = parseGdtfDescription(_wiringXml);

      final fuse = fixtureType.wiringObjectByName('Fuse')!;
      expect(fuse.componentType, GDTFComponentType.fuse);
      expect(fuse.fuseCurrent, closeTo(10, 1e-9));
      expect(fuse.fuseRating, GDTFFuseRating.c);
      expect(fuse.connectorType, isNull);
      expect(fuse.signalType, isNull);
      expect(fuse.signalLayer, isNull);
      expect(fuse.orientation, isNull);
      expect(fuse.pinCount, 0);
      expect(fuse.wireGroup, '');
      expect(fuse.pinPatches, isEmpty);
    });

    test('Custom connector and signal types are preserved verbatim', () {
      final fixtureType = parseGdtfDescription(_wiringXml);

      final ethernet = fixtureType.wiringObjectByName('Ethernet')!;
      expect(ethernet.connectorType, const GDTFCustomConnectorType('etherCON'));
      expect(ethernet.signalType, const GDTFCustomSignalType('Ethernet'));
      expect(ethernet.componentType, GDTFComponentType.networkInOut);
    });

    test('Parses pin patches and resolves their target by name', () {
      final fixtureType = parseGdtfDescription(_wiringXml);

      final patch =
          fixtureType.wiringObjectByName('Power IN')!.pinPatches.single;
      expect(patch.toWiringObjectName, 'Fuse');
      expect(patch.fromPin, 1);
      expect(patch.toPin, 2);
      expect(
        fixtureType.wiringObjectByName(patch.toWiringObjectName),
        same(fixtureType.wiringObjectByName('Fuse')),
      );
      expect(fixtureType.wiringObjectByName('Nope'), isNull);
    });

    test('Flattens wiring objects with fixture-local transforms', () {
      final fixtureType = parseGdtfDescription(_wiringXml);

      // Four on the panel plus the DMX port instanced twice.
      final instances = fixtureType.wiringObjects;
      expect(instances.map((i) => i.wiringObject.name), [
        'Power IN',
        'Power THRU',
        'Fuse',
        'Ethernet',
        'DMX',
        'DMX',
      ]);

      final thru = instances[1].location;
      expect(thru.x, closeTo(100, 1e-6));
      expect(thru.y, closeTo(50, 1e-6));
      expect(thru.z, closeTo(0, 1e-6));

      // Instanced at each reference's position; the Port tree's own 1m Z
      // offset is ignored.
      expect(instances[4].location.x, closeTo(-100, 1e-6));
      expect(instances[5].location.x, closeTo(-50, 1e-6));
      expect(instances[4].location.z, closeTo(0, 1e-6));
      expect(
        instances[4].wiringObject.connectorType,
        GDTFPredefinedConnectorType.xlr5,
      );
      expect(instances[4].wiringObject.signalLayer, 0);
    });

    test('wiringObjectsForMode follows the mode geometry and falls back', () {
      final fixtureType = parseGdtfDescription(_wiringXml);

      expect(fixtureType.wiringObjectsForMode('Mode').length, 6);

      final portOnly = fixtureType.wiringObjectsForMode('Port Only');
      expect(portOnly.single.wiringObject.name, 'DMX');
      expect(portOnly.single.location.z, closeTo(1000, 1e-6));

      expect(fixtureType.wiringObjectsForMode('Unknown').length, 6);
    });

    test('Wiring objects remain in the geometry tree', () {
      final fixtureType = parseGdtfDescription(_wiringXml);

      final panel = fixtureType.geometries.first.children.first;
      expect(panel.children.length, 4);
      expect(panel.children, everyElement(isA<GDTFWiringObject>()));
    });

    test('Fixtures without wiring objects expose an empty list', () {
      final fixtureType = parseGdtfDescription(_movingHeadXml);

      expect(fixtureType.wiringObjects, isEmpty);
      expect(fixtureType.wiringObjectsForMode('Mode 1'), isEmpty);
    });
  });

  group('parseGdtfDescription metadata and models', () {
    test('Parses FixtureType attributes', () {
      final fixtureType = parseGdtfDescription(_movingHeadXml);

      expect(fixtureType.dataVersion, '1.2');
      expect(fixtureType.name, 'Test Head');
      expect(fixtureType.shortName, 'TH');
      expect(fixtureType.longName, 'Test Moving Head');
      expect(fixtureType.manufacturer, 'Acme');
      expect(fixtureType.description, 'A test fixture');
      expect(fixtureType.fixtureTypeId, '12345678-AAAA-BBBB-CCCC-1234567890AB');
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

    test(
      'Instantiates GeometryReference targets at the reference position',
      () {
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
      },
    );

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
