import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mvr/errors/file_not_found_error.dart';
import 'package:mvr/src/mvr_main.dart';

import '../test_parameters/test_parameters.dart';

import 'package:path/path.dart' as p;

void main() async {
  test('Smoke test MVR.read() function.', () async {
    final mvr = MVR(filePath: generalMvrTestParameters.filePath);
    final testResult = await mvr.read();
    expect(testResult, true, reason: 'MVR.read() returned false');
  });

  group("Test graceful handling of file errors.", () {
    test('Test graceful handling of blank file paths', () async {
      final mvr = MVR(filePath: '');

      try {
        await mvr.read();
      } catch (error) {
        expect(
          error.runtimeType,
          MvrInvalidFilePathError,
          reason:
              'A blank file path was provided, but did not trigger the correct error',
        );
      }
    });

    test('Test for gracefull handling of a file that does not exist', () async {
      final mvr = MVR(
        filePath: p.join(
          Directory.current.path,
          'a_file_that_doesnt_actually_exist.mvr',
        ),
      );

      try {
        await mvr.read();
      } catch (error) {
        expect(
          error.runtimeType,
          MVRFileNotFoundError,
          reason:
              'A file that does not exist was provided, but the class failed to gracefully throw an exception.',
        );
      }
    });

    test('Test for gracefull handling of a super invalid mvr file', () async {
      final mvr = MVR(filePath: generalMvrTestParameters.invalidFilePath);

      try {
        await mvr.read();
      } catch (error) {
        expect(
          error.runtimeType,
          MvrInvalidFileError,
          reason:
              'A file with invalid contents was provided, but the class did not fail gracefully.',
        );
      }
    });
  });

  group('Testing for correct MVR class state after read() function.', () {
    test('Testing that GDTF files are correctly ignored', () async {
      final mvr = MVR(filePath: generalMvrTestParameters.filePath);
      await mvr.read(expandGdtfFiles: false);

      expect(
        mvr.gdtfContents.length,
        0,
        reason:
            'MVR.gdtfContents.length was not zero when no gdtf files should have been expanded',
      );
    });

    test('Testing that GDTF files are expanded as expected', () async {
      final mvr = MVR(filePath: generalMvrTestParameters.filePath);
      await mvr.read(expandGdtfFiles: true);

      expect(
        mvr.gdtfContents.length,
        generalMvrTestParameters.gdtfFileCount,
        reason: 'MVR.gdtfContents.length did not match the expected count',
      );
    });

    test('Testing that the GSD is intialized.', () async {
      final mvr = MVR(filePath: generalMvrTestParameters.filePath);
      await mvr.read(expandGdtfFiles: false);

      expect(
        mvr.generalSceneDescription.layers.length,
        generalMvrTestParameters.layerCount,
        reason: 'Qty of layers does not match expected ammount.',
      );
    });
  });

  group('Test more specific aspects of the General Scene Description', () {
    test(
      'Test that the correct number of Fixtures have been initialized.',
      () async {
        final mvr = MVR(filePath: generalMvrTestParameters.filePath);
        await mvr.read(expandGdtfFiles: false);

        expect(
          mvr.generalSceneDescription.layers
              .expand((layer) => layer.fixtures)
              .length,
          generalMvrTestParameters.totalFixtureCount,
          reason: 'Qty of Fixtures does not match the expected ammout.',
        );
      },
    );

    test('Test that each Fixture has a unique UUID', () async {
      final mvr = MVR(filePath: generalMvrTestParameters.filePath);
      await mvr.read(expandGdtfFiles: false);

      expect(
        mvr.generalSceneDescription.layers
            .expand((layer) => layer.fixtures)
            .map((fix) => fix.uuid)
            .toSet()
            .length,
        generalMvrTestParameters.totalFixtureCount,
        reason: 'Qty of unique Fixture UUIDs is not expected',
      );
    });

    test('Test that each Fixture has a unique FixtureID', () async {
      final mvr = MVR(filePath: generalMvrTestParameters.filePath);
      await mvr.read(expandGdtfFiles: false);

      expect(
        mvr.generalSceneDescription.layers
            .expand((layer) => layer.fixtures)
            .map((fix) => fix.fixtureId)
            .toSet()
            .length,
        generalMvrTestParameters.totalFixtureCount,
        reason: 'Qty of unique Numeric Fixture IDs is not expected',
      );
    });

    test('Test that every fixture has a valid DMX address', () async {
      final mvr = MVR(filePath: generalMvrTestParameters.filePath);
      await mvr.read(expandGdtfFiles: false);

      expect(
        mvr.generalSceneDescription.layers
            .expand((layer) => layer.fixtures)
            .map((fix) => fix.addresses.singleGlobalAddress ?? 0)
            .toSet()
            .length,
        generalMvrTestParameters.totalFixtureCount,
        reason: 'Qty of unique Numeric Fixture IDs is not expected',
      );
    });

    test('Test that fixtures have mostly correct gdtf references', () async {
      final mvr = MVR(filePath: generalMvrTestParameters.filePath);
      await mvr.read(expandGdtfFiles: false);

      expect(
        mvr.generalSceneDescription.layers
            .expand((layer) => layer.fixtures)
            .map((fix) => fix.gdtfSpec)
            .toSet()
            .length,
        generalMvrTestParameters.gdtfFileCount,
        reason:
            'Qty of unique references to gdtfSpec does not match the expected count of GDTF files in the MVR archive.',
      );
    });

    test('Test that the first fixture has the correct properties', () async {
      final mvr = MVR(filePath: generalMvrTestParameters.filePath);
      await mvr.read(expandGdtfFiles: false);

      final fixture =
          mvr.generalSceneDescription.layers
              .expand((layer) => layer.fixtures)
              .first;

      expect(
        fixture.uuid,
        "EAF9B53D-9ABE-1002-CC90-F72241CE4801",
        reason: 'Unexpected Fixture UUID',
      );

      expect(fixture.name, "Xtylos 1", reason: 'Unexpected Name');

      expect(
        fixture.gdtfSpec,
        "Clay Paky@Xtylos",
        reason: 'Unexpected GdtfSpec',
      );
      expect(fixture.gdtfMode, "Mode 0", reason: 'Unexpected GdtfSpec');

      expect(
        fixture.addresses.singleGlobalAddress,
        1,
        reason: 'Unexpected Address',
      );
      expect(fixture.unitNumber, 0, reason: 'Unexpected UnitNumber');
      expect(fixture.castShadow, false, reason: 'Unexpected GdtfSpec');
    });
  });
}
