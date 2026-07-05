import 'package:flutter_test/flutter_test.dart';
import 'package:mvr/src/classes/mvr_graphic_objects.dart';
import 'package:mvr/src/mvr_main.dart';

import '../test_parameters/test_parameters.dart';

/// End-to-end coverage for Truss support: reads a real `.mvr` archive and
/// verifies that trusses are parsed and that their physical size is resolved
/// from the referenced Symdef geometry (glb) via the [Context] lookup.
void main() {
  group('End-to-end Truss parsing from truss.mvr', () {
    late MVR mvr;

    setUp(() async {
      mvr = MVR(filePath: trussTestParams.filePath);
      await mvr.read(expandGdtfFiles: false);
    });

    test('Reads the expected number of layers', () {
      expect(
        mvr.generalSceneDescription.layers.length,
        trussTestParams.layerCount,
        reason: 'Unexpected layer count',
      );
    });

    test('Parses every Truss in the scene', () {
      final trusses =
          mvr.generalSceneDescription.layers
              .expand((layer) => layer.children)
              .whereType<MVRTruss>()
              .toList();

      expect(
        trusses.length,
        trussTestParams.trussCount,
        reason: 'Unexpected number of MVRTruss objects',
      );
    });

    test('Trusses have the expected UUIDs and name', () {
      final trusses =
          mvr.generalSceneDescription.layers
              .expand((layer) => layer.children)
              .whereType<MVRTruss>()
              .toList();

      expect(
        trusses.map((t) => t.uuid).toList(),
        trussTestParams.trussUuids,
        reason: 'Unexpected Truss UUIDs',
      );

      for (final truss in trusses) {
        expect(
          truss.name,
          trussTestParams.trussName,
          reason: 'Unexpected Truss name',
        );
      }
    });

    test('Truss size is resolved from the referenced Symdef geometry', () {
      final trusses =
          mvr.generalSceneDescription.layers
              .expand((layer) => layer.children)
              .whereType<MVRTruss>()
              .toList();

      for (final truss in trusses) {
        expect(
          truss.length,
          closeTo(trussTestParams.expectedLength, 1e-6),
          reason: 'Truss length was not resolved from glb geometry',
        );
        expect(
          truss.width,
          closeTo(trussTestParams.expectedWidth, 1e-6),
          reason: 'Truss width was not resolved from glb geometry',
        );
        expect(
          truss.height,
          closeTo(trussTestParams.expectedHeight, 1e-6),
          reason: 'Truss height was not resolved from glb geometry',
        );
      }
    });

    test('Truss geometry resolves to a non-zero size', () {
      // Guards against regressions where the Symdef/geometry lookup silently
      // falls through to the (0, 0, 0) default.
      final truss =
          mvr.generalSceneDescription.layers
              .expand((layer) => layer.children)
              .whereType<MVRTruss>()
              .first;

      expect(truss.length, greaterThan(0));
      expect(truss.width, greaterThan(0));
      expect(truss.height, greaterThan(0));
    });

    test('Trusses carry through their transform matrix', () {
      final trusses =
          mvr.generalSceneDescription.layers
              .expand((layer) => layer.children)
              .whereType<MVRTruss>()
              .toList();

      // Both trusses sit on the same Y plane but at different X positions,
      // confirming each node keeps its own Matrix rather than sharing one.
      expect(trusses[0].matrix.y, -4100.0);
      expect(trusses[1].matrix.y, -4100.0);
      expect(
        trusses[0].matrix.x,
        isNot(equals(trusses[1].matrix.x)),
        reason: 'Each Truss should retain its own translation',
      );
    });
  });
}
