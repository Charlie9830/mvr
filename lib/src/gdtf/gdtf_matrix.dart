import 'package:mvr/src/classes/xml_nodes/value_nodes/matrix.dart';

final _groupPattern = RegExp(r'\{([^{}]*)\}');

/// Parses a GDTF `Matrix` attribute value into an [MVRMatrix].
///
/// GDTF stores a 4x4 float matrix row-major —
/// `{r00,r01,r02,tx}{r10,r11,r12,ty}{r20,r21,r22,tz}{0,0,0,1}` — with the
/// rotation in the first three columns, the translation in the fourth column
/// and translation units in metres.
///
/// The MVR matrix convention instead keeps the basis vectors in rows 0-2, the
/// translation in row 3 and translation units in mm, so the rotation is
/// transposed and the translation scaled during conversion. Both spaces are
/// right-handed and Z-up, so no axis conversion is required.
///
/// Returns the identity matrix when [value] is null, empty or not a valid
/// 4x4 GDTF matrix.
MVRMatrix parseGdtfMatrix(String? value) {
  if (value == null || value.trim().isEmpty) {
    return const MVRMatrix.identity();
  }

  final groups =
      _groupPattern
          .allMatches(value)
          .map(
            (match) =>
                match
                    .group(1)!
                    .split(',')
                    .map((component) => double.tryParse(component.trim()))
                    .toList(),
          )
          .toList();

  // Only the first three rows carry information; the fourth row is always
  // {0,0,0,1} and is tolerated as absent.
  if (groups.length < 3 ||
      groups
          .take(3)
          .any((row) => row.length < 4 || row.any((v) => v == null))) {
    return const MVRMatrix.identity();
  }

  final r0 = groups[0];
  final r1 = groups[1];
  final r2 = groups[2];

  return MVRMatrix([
    [r0[0]!, r1[0]!, r2[0]!],
    [r0[1]!, r1[1]!, r2[1]!],
    [r0[2]!, r1[2]!, r2[2]!],
    [r0[3]! * 1000, r1[3]! * 1000, r2[3]! * 1000],
  ]);
}
