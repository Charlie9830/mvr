import 'package:flutter_test/flutter_test.dart';
import 'package:mvr/src/classes/mvr_graphic_objects.dart';
import 'package:mvr/src/mvr_main.dart';

import '../test_parameters/test_parameters.dart';

/// End-to-end coverage for Truss support: reads a real `.mvr` archive and
/// verifies that trusses are parsed and that their world-space bounding box is
/// resolved from the referenced Symdef geometry (glb) via the [Context] lookup
/// and each truss's transform matrix.
void main() {
  group('End-to-end Truss parsing from truss.mvr', () {
    late MVR mvr;

    List<MVRTruss> trussesOf(MVR mvr) => mvr.generalSceneDescription.layers
        .expand((layer) => layer.children)
        .whereType<MVRTruss>()
        .toList();

    setUp(() async {
      mvr = MVR(filePath: trussTestParams.filePath);
      await mvr.read(parseGdtfFiles: false);
    });

    test('Reads the expected number of layers', () {
      expect(
        mvr.generalSceneDescription.layers.length,
        trussTestParams.layerCount,
        reason: 'Unexpected layer count',
      );
    });

    test('Parses every Truss in the scene', () {
      expect(
        trussesOf(mvr).length,
        trussTestParams.trussCount,
        reason: 'Unexpected number of MVRTruss objects',
      );
    });

    test('Trusses have the expected UUIDs', () {
      expect(
        trussesOf(mvr).map((t) => t.uuid).toSet(),
        trussTestParams.trusses.map((t) => t.uuid).toSet(),
        reason: 'Unexpected Truss UUIDs',
      );
    });

    test('Each Truss has the expected name', () {
      for (final truss in trussesOf(mvr)) {
        final expected = trussTestParams.trussByUuid(truss.uuid);
        expect(truss.name, expected.name, reason: 'Unexpected Truss name');
      }
    });

    test('Each Truss carries through its own transform matrix', () {
      for (final truss in trussesOf(mvr)) {
        final expected = trussTestParams.trussByUuid(truss.uuid);
        expect(truss.matrix.x, closeTo(expected.matrixX, 1e-6));
        expect(truss.matrix.y, closeTo(expected.matrixY, 1e-6));
        expect(truss.matrix.z, closeTo(expected.matrixZ, 1e-6));
      }
    });

    test('Truss bounding box size is resolved from the Symdef geometry', () {
      for (final truss in trussesOf(mvr)) {
        final expected = trussTestParams.trussByUuid(truss.uuid);
        expect(
          truss.boundingBox.length,
          closeTo(expected.length, 1e-3),
          reason: 'Truss length was not resolved from glb geometry',
        );
        expect(
          truss.boundingBox.width,
          closeTo(expected.width, 1e-3),
          reason: 'Truss width was not resolved from glb geometry',
        );
        expect(
          truss.boundingBox.height,
          closeTo(expected.height, 1e-3),
          reason: 'Truss height was not resolved from glb geometry',
        );
      }
    });

    test('Truss geometry resolves to a non-zero size', () {
      // Guards against regressions where the Symdef/geometry lookup silently
      // falls through to the (0, 0, 0) default.
      for (final truss in trussesOf(mvr)) {
        expect(truss.boundingBox.length, greaterThan(0));
        expect(truss.boundingBox.width, greaterThan(0));
        expect(truss.boundingBox.height, greaterThan(0));
      }
    });

    test('Truss bounding box centre matches the transformed geometry', () {
      for (final truss in trussesOf(mvr)) {
        final expected = trussTestParams.trussByUuid(truss.uuid);

        expect(truss.boundingBox.corners.length, 8);
        expect(truss.center, equals(truss.boundingBox.center));

        expect(truss.center.x, closeTo(expected.centerX, 1e-3));
        expect(truss.center.y, closeTo(expected.centerY, 1e-3));
        expect(truss.center.z, closeTo(expected.centerZ, 1e-3));

        // The centre sits at the midpoint of the world box on every axis.
        expect(truss.center.x, closeTo(
            (truss.boundingBox.min.x + truss.boundingBox.max.x) / 2, 1e-6));
        expect(truss.center.y, closeTo(
            (truss.boundingBox.min.y + truss.boundingBox.max.y) / 2, 1e-6));
        expect(truss.center.z, closeTo(
            (truss.boundingBox.min.z + truss.boundingBox.max.z) / 2, 1e-6));
      }
    });

    test('Rotated trusses grow their world-aligned extents', () {
      // The "3m Angled" trusses share geometry with the straight trusses but
      // are rotated, so their world-aligned bounding box is larger than the
      // un-rotated 3m truss on at least one axis.
      final straight = trussesOf(mvr).firstWhere((t) => t.name == '3m Straight');
      final angled = trussesOf(mvr).where((t) => t.name == '3m Angled');

      for (final truss in angled) {
        final grewHorizontally =
            truss.boundingBox.width > straight.boundingBox.width + 1;
        final grewVertically =
            truss.boundingBox.height > straight.boundingBox.height + 1;
        expect(
          grewHorizontally || grewVertically,
          isTrue,
          reason: 'A rotated truss should enlarge its world-aligned box',
        );
      }
    });
  });
}
