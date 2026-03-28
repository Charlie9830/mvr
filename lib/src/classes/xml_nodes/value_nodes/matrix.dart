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
