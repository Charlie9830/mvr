import 'package:flutter_test/flutter_test.dart';
import 'package:mvr/src/classes/mvr_vector3.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/matrix.dart';
import 'package:mvr/src/gdtf/gdtf_matrix.dart';

void main() {
  group('parseGdtfMatrix', () {
    test('Parses an identity matrix', () {
      final matrix = parseGdtfMatrix(
        '{1.000000,0.000000,0.000000,0.000000}'
        '{0.000000,1.000000,0.000000,0.000000}'
        '{0.000000,0.000000,1.000000,0.000000}'
        '{0,0,0,1}',
      );

      final p = matrix.transform(MVRVector3(1, 2, 3));
      expect(p.x, closeTo(1, 1e-9));
      expect(p.y, closeTo(2, 1e-9));
      expect(p.z, closeTo(3, 1e-9));
    });

    test('Converts the metre translation column into mm', () {
      // Third row carries tz = -0.19 m, i.e. -190 mm.
      final matrix = parseGdtfMatrix(
        '{1.000000,0.000000,0.000000,0.100000}'
        '{0.000000,1.000000,0.000000,0.000000}'
        '{0.000000,0.000000,1.000000,-0.190000}'
        '{0,0,0,1}',
      );

      expect(matrix.x, closeTo(100, 1e-9));
      expect(matrix.y, closeTo(0, 1e-9));
      expect(matrix.z, closeTo(-190, 1e-9));
    });

    test('Transposes the GDTF row-major rotation into MVR basis rows', () {
      // Rotation of 90 degrees about Z in GDTF (row-major, column-vector)
      // form: rows [[0,-1,0],[1,0,0],[0,0,1]].
      final matrix = parseGdtfMatrix(
        '{0,-1,0,0}{1,0,0,0}{0,0,1,0}{0,0,0,1}',
      );

      final p = matrix.transform(MVRVector3(1, 0, 0));
      expect(p.x, closeTo(0, 1e-9));
      expect(p.y, closeTo(1, 1e-9));
      expect(p.z, closeTo(0, 1e-9));

      expect(matrix.rotationZ, closeTo(90, 1e-6));
    });

    test('Tolerates a missing {0,0,0,1} row', () {
      final matrix = parseGdtfMatrix(
        '{1,0,0,0.5}{0,1,0,0}{0,0,1,0}',
      );

      expect(matrix.x, closeTo(500, 1e-9));
    });

    test('Falls back to identity for null, empty or malformed input', () {
      for (final input in [null, '', '{1,0,0}{0,1,0}{0,0,1}{0,0,0}', 'junk']) {
        final matrix = parseGdtfMatrix(input);
        final p = matrix.transform(MVRVector3(7, 8, 9));
        expect(p, equals(MVRVector3(7, 8, 9)), reason: 'input: $input');
      }
    });
  });

  group('MVRMatrix.multiply', () {
    test('Composes translation with translation', () {
      final parent = MVRMatrix([
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [10, 20, 30],
      ]);
      final child = MVRMatrix([
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [1, 2, 3],
      ]);

      final composed = parent.multiply(child);
      final p = composed.transform(MVRVector3.zero);

      expect(p.x, closeTo(11, 1e-9));
      expect(p.y, closeTo(22, 1e-9));
      expect(p.z, closeTo(33, 1e-9));
    });

    test('Matches transforming through parent and child sequentially', () {
      // Parent: rotate 90 degrees about Z then translate (10, 0, 0).
      final parent = MVRMatrix([
        [0, 1, 0],
        [-1, 0, 0],
        [0, 0, 1],
        [10, 0, 0],
      ]);
      final child = MVRMatrix([
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [5, 0, 0],
      ]);

      final composed = parent.multiply(child);

      for (final point in [
        MVRVector3.zero,
        MVRVector3(1, 2, 3),
        MVRVector3(-4, 0.5, 12),
      ]) {
        final expected = parent.transform(child.transform(point));
        final actual = composed.transform(point);

        expect(actual.x, closeTo(expected.x, 1e-9));
        expect(actual.y, closeTo(expected.y, 1e-9));
        expect(actual.z, closeTo(expected.z, 1e-9));
      }
    });
  });
}
