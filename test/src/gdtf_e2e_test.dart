import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mvr/errors/gdtf_errors.dart';
import 'package:mvr/src/classes/gdtf/gdtf_connector_type.dart';
import 'package:mvr/src/classes/gdtf/gdtf_signal_type.dart';
import 'package:mvr/src/classes/gdtf/gdtf_wiring_object.dart';
import 'package:mvr/src/classes/mvr_graphic_objects.dart';
import 'package:mvr/src/gdtf_main.dart';
import 'package:mvr/src/mvr_main.dart';
import 'package:path/path.dart' as p;

import '../test_parameters/test_parameters.dart';

final _sharpyGdtfPath = p.join(
  Directory.current.path,
  'test_files',
  'Clay Paky@Sharpy.gdtf',
);

/// Expected Sharpy bounds (mm), derived from its description.xml:
/// base 405x405x85.5 at the origin, yoke 0.19m below, head a further 0.0836m
/// below, beam 0.1235m below that. Boxes are centred on each part's origin.
const _sharpyLength = 405.0;
const _sharpyWidth = 405.0;
const _sharpyHeight = 444.85;

void main() {
  group('End-to-end GDTF parsing from general.mvr', () {
    late MVR mvr;

    setUp(() async {
      mvr = MVR(filePath: generalMvrTestParameters.filePath);
      await mvr.read();
    });

    test('Parses a fixture type for every GDTF file in the archive', () {
      expect(
        mvr.gdtfFixtureTypes.length,
        generalMvrTestParameters.gdtfFileCount,
      );

      for (final entry in mvr.gdtfFixtureTypes.entries) {
        expect(
          entry.value.boundingBox.height,
          greaterThan(0),
          reason: '${entry.key} resolved to a zero-height bounding box',
        );
        expect(
          entry.value.dmxModes,
          isNotEmpty,
          reason: '${entry.key} has no DMX modes',
        );
      }
    });

    test('Every fixture in the scene resolves to its fixture type', () {
      final fixtures =
          mvr.generalSceneDescription.layers
              .expand((layer) => layer.children)
              .whereType<MVRFixture>();

      for (final fixture in fixtures) {
        expect(
          mvr.fixtureTypeOf(fixture),
          isNotNull,
          reason:
              'Fixture ${fixture.name} (${fixture.gdtfSpec}) did not resolve '
              'to a GDTF fixture type',
        );
      }
    });

    test('Lookup tolerates the .gdtf extension being present or absent', () {
      expect(mvr.fixtureTypeByName('Clay Paky@Sharpy'), isNotNull);
      expect(mvr.fixtureTypeByName('Clay Paky@Sharpy.gdtf'), isNotNull);
      expect(mvr.fixtureTypeByName('clay paky@sharpy'), isNotNull);
      expect(mvr.fixtureTypeByName('Not A Fixture'), isNull);
      expect(mvr.fixtureTypeByName(''), isNull);
    });

    test('The Sharpy geometry resolves to its physical dimensions', () {
      final sharpy = mvr.fixtureTypeByName('Clay Paky@Sharpy')!;

      expect(sharpy.manufacturer, 'Clay Paky');
      expect(sharpy.dmxModes.length, 4);

      final box = sharpy.boundingBox;
      expect(box.length, closeTo(_sharpyLength, 1e-3));
      expect(box.width, closeTo(_sharpyWidth, 1e-3));
      expect(box.height, closeTo(_sharpyHeight, 1e-3));

      // The base sits at the origin; everything else hangs below it.
      expect(box.max.z, closeTo(85.5 / 2, 1e-3));

      // Base, yoke, head and beam.
      expect(sharpy.partsForMode('Standard Lamp on').length, 4);

      // Every mode of the Sharpy describes the same physical device.
      for (final mode in sharpy.dmxModes) {
        expect(
          sharpy.boundingBoxForMode(mode.name).height,
          closeTo(_sharpyHeight, 1e-3),
          reason: 'Unexpected height for mode ${mode.name}',
        );
      }
    });

    test('The MAC Aura XIP exposes its wiring objects', () {
      final aura = mvr.fixtureTypeByName('BLD@Martin MAC Aura XIP')!;

      final wiring = aura.wiringObjects.map((i) => i.wiringObject).toList();
      expect(wiring.map((w) => w.name), [
        'Power IN',
        'Power THRU',
        'DMX IN',
        'DMX THRU',
        'Ethernet IN',
        'Ethernet THRU',
      ]);

      final powerIn = wiring.first;
      expect(powerIn.componentType, GDTFComponentType.consumer);
      expect(
        powerIn.connectorType,
        GDTFPredefinedConnectorType.powerconTrue1Top,
      );
      expect(powerIn.signalType, GDTFPredefinedSignalType.power);
      expect(powerIn.electricalPayLoad, closeTo(285, 1e-9));

      final dmxIn = wiring[2];
      expect(dmxIn.componentType, GDTFComponentType.input);
      expect(dmxIn.connectorType, GDTFPredefinedConnectorType.xlr5);
      expect(dmxIn.signalType, GDTFPredefinedSignalType.dmx512);
      expect(dmxIn.pinCount, 5);

      // etherCON is not an Annex D type.
      final ethernetIn = wiring[4];
      expect(
        ethernetIn.connectorType,
        const GDTFCustomConnectorType('etherCON'),
      );
      expect(ethernetIn.signalType, const GDTFCustomSignalType('Ethernet'));

      for (final mode in aura.dmxModes) {
        expect(aura.wiringObjectsForMode(mode.name).length, 6);
      }
    });

    test('GeometryReference-based battens union their referenced pixels', () {
      final bar = mvr.fixtureTypeByName('GLP@impression X5ip Bar 1000')!;

      // The 1m bar body defines the length; lens pixels are instanced
      // along it via GeometryReference nodes.
      expect(bar.boundingBox.length, closeTo(1000, 1.0));
      expect(
        bar.parts.length,
        greaterThan(2),
        reason:
            'Expected the bar to flatten into multiple parts (body + '
            'instanced pixels)',
      );
    });
  });

  group('Standalone GDTF file reading', () {
    test('Smoke test GDTF.read()', () async {
      final gdtf = GDTF(filePath: _sharpyGdtfPath);
      final result = await gdtf.read();

      expect(result, true, reason: 'GDTF.read() returned false');

      expect(gdtf.fixtureType.name, 'Dummy - Sharpy');
      expect(gdtf.fixtureType.manufacturer, 'Clay Paky');
      expect(gdtf.fixtureType.dataVersion, '1.2');
      expect(
        gdtf.fixtureType.fixtureTypeId,
        'BD38A30B-6E38-100A-1704-DC95116EC21D',
      );
      expect(gdtf.fixtureType.boundingBox.height, closeTo(_sharpyHeight, 1e-3));
    });

    test('Accessing fixtureType before read() throws', () {
      final gdtf = GDTF(filePath: _sharpyGdtfPath);
      expect(() => gdtf.fixtureType, throwsA(anything));
    });

    test('A blank file path throws GdtfInvalidFilePathError', () async {
      final gdtf = GDTF(filePath: '');
      await expectLater(gdtf.read(), throwsA(isA<GdtfInvalidFilePathError>()));
    });

    test('A missing file throws GdtfFileNotFoundError', () async {
      final gdtf = GDTF(
        filePath: p.join(Directory.current.path, 'does_not_exist.gdtf'),
      );
      await expectLater(gdtf.read(), throwsA(isA<GdtfFileNotFoundError>()));
    });

    test(
      'A file that is not a zip archive throws GdtfInvalidFileError',
      () async {
        final gdtf = GDTF(filePath: generalMvrTestParameters.invalidFilePath);
        await expectLater(gdtf.read(), throwsA(isA<GdtfInvalidFileError>()));
      },
    );
  });
}
