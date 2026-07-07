import 'package:mvr/src/classes/mvr_vector3.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:collection/collection.dart';
import 'package:xml/xml.dart';
import 'dart:math' as math;

class MatrixValueNode extends MVRValueNode<MVRMatrix> {
  MatrixValueNode(super.value) : super(tagName: 'Matrix');

  factory MatrixValueNode.from(XmlElement element) {
    return MatrixValueNode(MVRMatrix.fromString(element.innerText));
  }
}

// Represents the MVR Matrix Attribute.
// From the Spec;
// -- Right-handed
// -- Z-Up
// -- 1 Distance Unit equals 1 mm
class MVRMatrix {
  final List<List<double>> matrix;

  MVRMatrix(this.matrix);

  const MVRMatrix.identity()
    : matrix = const [
        [1.0, 0, 0],
        [0, 1.0, 0],
        [0, 0, 1.0],
        [0, 0, 0],
      ];

  /// The X translation component of the matrix (in mm).
  double get x => matrix[3][0];

  /// The Y translation component of the matrix (in mm).
  double get y => matrix[3][1];

  /// The Z translation component of the matrix (in mm).
  double get z => matrix[3][2];

  /// The rotation around the X axis in degrees.
  double get rotationX =>
      math.atan2(matrix[1][2], matrix[2][2]) * 180 / math.pi;

  /// The rotation around the Y axis in degrees.
  double get rotationY =>
      math.asin(matrix[0][2].clamp(-1.0, 1.0)) * -180 / math.pi;

  /// The rotation around the Z axis in degrees.
  double get rotationZ =>
      math.atan2(matrix[0][1], matrix[0][0]) * 180 / math.pi;

  /// The world-space direction of the local X (length) axis.
  ///
  /// This is the image of the local unit X vector under the matrix, i.e. the
  /// first basis row. It is generally unit-length but may carry scale, so
  /// callers that need a direction should normalise it.
  MVRVector3 get xAxis => MVRVector3(matrix[0][0], matrix[0][1], matrix[0][2]);

  /// The world-space direction of the local Y (width) axis.
  MVRVector3 get yAxis => MVRVector3(matrix[1][0], matrix[1][1], matrix[1][2]);

  /// The world-space direction of the local Z (height) axis.
  MVRVector3 get zAxis => MVRVector3(matrix[2][0], matrix[2][1], matrix[2][2]);

  /// Transforms a point from the matrix's local space into world space.
  ///
  /// The MVR matrix stores the three basis vectors in rows 0-2 and the
  /// translation in row 3, so a local point maps to
  /// `local.x * row0 + local.y * row1 + local.z * row2 + translation`.
  MVRVector3 transform(MVRVector3 local) {
    return MVRVector3(
      local.x * matrix[0][0] +
          local.y * matrix[1][0] +
          local.z * matrix[2][0] +
          matrix[3][0],
      local.x * matrix[0][1] +
          local.y * matrix[1][1] +
          local.z * matrix[2][1] +
          matrix[3][1],
      local.x * matrix[0][2] +
          local.y * matrix[1][2] +
          local.z * matrix[2][2] +
          matrix[3][2],
    );
  }

  @override
  String toString() {
    return matrix.map((row) => '{${row.join(',')}}').join('');
  }

  factory MVRMatrix.fromString(String value) {
    final matchCommasAndClosingCurlyBrackets = RegExp(r',|}');
    final matchOpeningBracketsAndWhitespace = RegExp(r'{|\s');

    final rows = value
        .split(matchCommasAndClosingCurlyBrackets)
        .map(
          (dirtyValue) =>
              dirtyValue.replaceAll(matchOpeningBracketsAndWhitespace, ''),
        )
        .slices(3);

    return MVRMatrix(
      rows
          .map(
            (row) =>
                row.map((value) => double.tryParse(value)).nonNulls.toList(),
          )
          .where((row) => row.isNotEmpty)
          .toList(),
    );
  }
}
